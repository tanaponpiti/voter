package service

import (
	"errors"
	"github.com/tanaponpiti/voter/voter_server/model"
	"github.com/tanaponpiti/voter/voter_server/repository"
	"github.com/tanaponpiti/voter/voter_server/response"
	"go.mongodb.org/mongo-driver/mongo"
	"net/http"
	"sort"
	"sync"
)

func GetAllVote() (voteWithScoreList []model.VoteWithScore, err error) {
	var wg sync.WaitGroup
	wg.Add(2)
	scoresChannel := make(chan []model.VoteScoreSummary, 1)
	choicesChannel := make(chan []model.VoteChoice, 1)
	errorChannel := make(chan error, 2)
	go func() {
		defer wg.Done()
		scores, err := repository.VoteLogRepositoryInstance.AggregateVoteScores()
		if err != nil {
			errorChannel <- err
			return
		}
		scoresChannel <- scores
	}()
	go func() {
		defer wg.Done()
		choices, err := repository.VoteChoiceRepositoryInstance.GetAllVoteChoices()
		if err != nil {
			errorChannel <- err
			return
		}
		choicesChannel <- choices
	}()
	wg.Wait()
	close(scoresChannel)
	close(choicesChannel)
	close(errorChannel)
	for err := range errorChannel {
		if err != nil {
			return nil, err
		}
	}
	scores := <-scoresChannel
	choices := <-choicesChannel
	if len(choices) > 0 {
		voteScoreMap := make(map[string]model.VoteScoreSummary)
		for _, score := range scores {
			voteScoreMap[score.VoteId] = score
		}
		for _, choice := range choices {
			voteId := choice.ID.Hex()
			voteScore, found := voteScoreMap[voteId]
			voteWithScore := model.VoteWithScore{
				ID:          choice.ID,
				Name:        choice.Name,
				Description: choice.Description,
				CreatedAt:   choice.CreatedAt,
				UpdatedAt:   choice.UpdatedAt,
				Score:       0,
			}
			if found {
				voteWithScore.Score = voteScore.VoteScore
			}
			voteWithScoreList = append(voteWithScoreList, voteWithScore)
		}
		sort.Slice(voteWithScoreList, func(i, j int) bool {
			return voteWithScoreList[j].Score < voteWithScoreList[i].Score
		})
		return voteWithScoreList, nil
	} else {
		return make([]model.VoteWithScore, 0), nil
	}
}

func CreateVoteChoice(insertData model.VoteChoiceInsertData) (err error) {
	_, err = repository.VoteChoiceRepositoryInstance.InsertVoteChoice(insertData)
	if err != nil {
		var mongoWriteException mongo.WriteException
		if errors.As(err, &mongoWriteException) {
			for _, err := range mongoWriteException.WriteErrors {
				if err.Code == 11000 { // 11000 is the error code for duplicate key error in MongoDB
					return response.NewErrorResponse("a vote choice with the same name already exists", http.StatusConflict)
				}
			}
		}
		return response.NewErrorResponse("failed to create the vote choice", http.StatusInternalServerError)
	}
	return nil
}

func EditVoteChoice(voteChoiceId string, data model.VoteChoiceUpdateData) (err error) {
	_, err = getVoteChoice(voteChoiceId)
	if err != nil {
		return err
	}
	score, err := countVoteScore(voteChoiceId)
	if err != nil {
		return err
	}
	if score > 0 {
		return response.NewErrorResponse("cannot edit vote choice that already have score", http.StatusConflict)
	}
	err = repository.VoteChoiceRepositoryInstance.UpdateVoteChoice(voteChoiceId, data)
	if err != nil {
		var mongoWriteException mongo.WriteException
		if errors.As(err, &mongoWriteException) {
			for _, err := range mongoWriteException.WriteErrors {
				if err.Code == 11000 { // 11000 is the error code for duplicate key error in MongoDB
					return response.NewErrorResponse("a vote choice with the same name already exists", http.StatusConflict)
				}
			}
		}
		return response.NewErrorResponse("failed to update the vote choice", http.StatusInternalServerError)
	}
	return nil
}

func getVoteChoice(voteChoiceId string) (voteChoice *model.VoteChoice, err error) {
	choice, err := repository.VoteChoiceRepositoryInstance.GetSingleVoteChoice(voteChoiceId)
	if err != nil {
		return nil, response.NewErrorResponse("unable to find vote choice", http.StatusInternalServerError)
	}
	if choice == nil {
		return nil, response.NewErrorResponse("vote choice not found", http.StatusNotFound)
	}
	return choice, nil
}

func countVoteScore(voteChoiceId string) (score int, err error) {
	score, err = repository.VoteLogRepositoryInstance.CountVoteLogByVoteId(voteChoiceId)
	if err != nil {
		return 0, response.NewErrorResponse("unable to find vote score of given vote choice", http.StatusInternalServerError)
	}
	return score, nil
}

func DeleteVoteChoice(voteChoiceId string) (err error) {
	_, err = getVoteChoice(voteChoiceId)
	if err != nil {
		return err
	}
	score, err := countVoteScore(voteChoiceId)
	if err != nil {
		return err
	}
	if score > 0 {
		return errors.New("cannot delete vote choice that already have score")
	}
	return repository.VoteChoiceRepositoryInstance.DeleteVoteChoice(voteChoiceId)
}

func VoteFor(voterId string, voteChoiceId string) (err error) {
	//check for vote exist
	_, err = getVoteChoice(voteChoiceId)
	if err != nil {
		return err
	}
	//check if given voterId already vote or not
	user, err := repository.UserRepositoryInstance.GetUser(voterId)
	if err != nil {
		return response.NewErrorResponse("unable to find user for vote", http.StatusBadRequest)
	}
	voteLog, err := repository.VoteLogRepositoryInstance.GetVoteLogByUserId(user.ID.Hex())
	if err != nil {
		return response.NewErrorResponse("unable to get vote log for user", http.StatusInternalServerError)
	}
	if voteLog != nil {
		return response.NewErrorResponse("user has already vote", http.StatusConflict)
	}
	_, err = repository.VoteLogRepositoryInstance.InsertVoteLog(model.VoteLog{VoteId: voteChoiceId, VoterUserId: voterId})
	if err != nil {
		return response.NewErrorResponse("unable to vote", http.StatusInternalServerError)
	}
	return nil
}

func DeleteAllVote() (err error) {
	_, err = repository.VoteChoiceRepositoryInstance.DeleteAllVoteChoice()
	if err != nil {
		return response.NewErrorResponse("failed to delete all vote choice", http.StatusInternalServerError)
	}
	_, err = repository.VoteLogRepositoryInstance.DeleteAllVoteLogs()
	if err != nil {
		return response.NewErrorResponse("failed to delete all vote log", http.StatusInternalServerError)
	}
	return nil
}
