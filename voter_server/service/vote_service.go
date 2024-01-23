package service

import (
	"errors"
	"github.com/tanaponpiti/voter/voter_server/model"
	"github.com/tanaponpiti/voter/voter_server/repository"
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
		return voteWithScoreList[i].Score < voteWithScoreList[j].Score
	})
	return voteWithScoreList, nil
}

func EditVoteChoice(voteChoiceId string, data model.VoteChoiceUpdateData) (err error) {
	choice, err := repository.VoteChoiceRepositoryInstance.GetSingleVoteChoice(voteChoiceId)
	if err != nil {
		return err
	}
	score, err := repository.VoteLogRepositoryInstance.CountVoteLogByVoteId(choice.ID.Hex())
	if err != nil {
		return err
	}
	if score > 0 {
		return errors.New("cannot edit vote choice that already have score")
	}
	return repository.VoteChoiceRepositoryInstance.UpdateVoteChoice(voteChoiceId, data)
}

func DeleteVoteChoice(voteChoiceId string) (err error) {
	choice, err := repository.VoteChoiceRepositoryInstance.GetSingleVoteChoice(voteChoiceId)
	if err != nil {
		return err
	}
	score, err := repository.VoteLogRepositoryInstance.CountVoteLogByVoteId(choice.ID.Hex())
	if err != nil {
		return err
	}
	if score > 0 {
		return errors.New("cannot delete vote choice that already have score")
	}
	return repository.VoteChoiceRepositoryInstance.DeleteVoteChoice(voteChoiceId)
}
