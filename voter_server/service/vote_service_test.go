package service

import (
	"errors"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
	"github.com/tanaponpiti/voter/voter_server/model"
	"github.com/tanaponpiti/voter/voter_server/repository"
	"github.com/tanaponpiti/voter/voter_server/repository/repository_test"
	"github.com/tanaponpiti/voter/voter_server/response"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"testing"
	"time"
)

func TestGetAllVote(t *testing.T) {
	mockVoteChoiceRepo := new(repository_test.VoteChoiceRepositoryMock)
	mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
	voteChoice1 := model.VoteChoice{
		ID:          primitive.NewObjectID(),
		Name:        "Choice 1",
		Description: "First choice",
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
	voteChoice2 := model.VoteChoice{
		ID:          primitive.NewObjectID(),
		Name:        "Choice 2",
		Description: "Second choice",
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
	voteScoreSummary1 := model.VoteScoreSummary{
		VoteId:    voteChoice1.ID.Hex(),
		VoteScore: 10,
	}
	voteScoreSummary2 := model.VoteScoreSummary{
		VoteId:    voteChoice2.ID.Hex(),
		VoteScore: 50,
	}
	mockVoteChoiceRepo.On("GetAllVoteChoices").Return([]model.VoteChoice{
		voteChoice1, voteChoice2,
	}, nil)

	mockVoteLogRepo.On("AggregateVoteScores").Return([]model.VoteScoreSummary{
		voteScoreSummary1, voteScoreSummary2,
	}, nil)

	repository.VoteChoiceRepositoryInstance = mockVoteChoiceRepo
	repository.VoteLogRepositoryInstance = mockVoteLogRepo

	result, err := GetAllVote()

	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Len(t, result, 2)
	require.Equal(t, voteScoreSummary1.VoteId, result[1].ID.Hex(), "The vote with the second highest score should be second")
	require.Equal(t, voteScoreSummary2.VoteId, result[0].ID.Hex(), "The vote with the highest score should be first")
}

func TestGetUserVoteLog(t *testing.T) {

	testVoterID := "testVoterID"

	t.Run("Success", func(t *testing.T) {
		mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
		repository.VoteLogRepositoryInstance = mockVoteLogRepo
		expectedVoteLog := &model.VoteLog{}
		mockVoteLogRepo.On("GetVoteLogByUserId", testVoterID).Return(expectedVoteLog, nil)

		result, err := GetUserVoteLog(testVoterID)

		require.NoError(t, err)
		assert.Equal(t, expectedVoteLog, result)
		mockVoteLogRepo.AssertExpectations(t)
	})

	t.Run("Error", func(t *testing.T) {
		mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
		repository.VoteLogRepositoryInstance = mockVoteLogRepo
		mockVoteLogRepo.On("GetVoteLogByUserId", testVoterID).Return(&model.VoteLog{}, errors.New("some error"))

		result, err := GetUserVoteLog(testVoterID)

		assert.Nil(t, result)
		assert.Error(t, err)
		assert.IsType(t, &response.ErrorResponse{}, err)
		mockVoteLogRepo.AssertExpectations(t)
	})
}

func TestCreateVoteChoice(t *testing.T) {
	t.Run("success case", func(t *testing.T) {
		mockVoteChoiceRepo := new(repository_test.VoteChoiceRepositoryMock)
		mockVoteChoiceRepo.On("InsertVoteChoice", mock.AnythingOfType("model.VoteChoiceInsertData")).Return(&mongo.InsertOneResult{}, nil)
		repository.VoteChoiceRepositoryInstance = mockVoteChoiceRepo

		err := CreateVoteChoice(model.VoteChoiceInsertData{
			Name: "Valid Name",
		})

		assert.NoError(t, err)
	})

	t.Run("error when name is empty", func(t *testing.T) {
		err := CreateVoteChoice(model.VoteChoiceInsertData{
			Name: "",
			// Populate other necessary fields
		})

		assert.Error(t, err)
		assert.Equal(t, "status 400: the name of the vote choice cannot be empty", err.Error())
	})

	t.Run("error on duplicate name", func(t *testing.T) {
		mockVoteChoiceRepo := new(repository_test.VoteChoiceRepositoryMock)
		writeErrors := []mongo.WriteError{{Code: 11000}}
		writeException := mongo.WriteException{WriteErrors: writeErrors}
		mockVoteChoiceRepo.On("InsertVoteChoice", mock.AnythingOfType("model.VoteChoiceInsertData")).Return(&mongo.InsertOneResult{}, writeException)
		repository.VoteChoiceRepositoryInstance = mockVoteChoiceRepo

		err := CreateVoteChoice(model.VoteChoiceInsertData{
			Name: "Duplicate Name",
			// Populate other necessary fields
		})

		assert.Error(t, err)
		assert.Equal(t, "status 409: a vote choice with the same name already exists", err.Error())
	})
}

func TestEditVoteChoice(t *testing.T) {

	voteChoiceObjectId := primitive.NewObjectID()
	voteChoiceId := voteChoiceObjectId.Hex()
	testVoteChoiceData := model.VoteChoice{
		ID:          voteChoiceObjectId,
		Name:        "firstname",
		Description: "for test only",
	}
	testUpdateData := model.VoteChoiceUpdateData{ /* Populate fields */ }

	t.Run("Success", func(t *testing.T) {
		mockVoteChoiceRepo := new(repository_test.VoteChoiceRepositoryMock)
		mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
		repository.VoteChoiceRepositoryInstance = mockVoteChoiceRepo
		repository.VoteLogRepositoryInstance = mockVoteLogRepo
		mockVoteChoiceRepo.On("GetSingleVoteChoice", voteChoiceId).Return(&testVoteChoiceData, nil)
		mockVoteLogRepo.On("CountVoteLogByVoteId", voteChoiceId).Return(0, nil)
		mockVoteChoiceRepo.On("UpdateVoteChoice", voteChoiceId, testUpdateData).Return(nil)
		err := EditVoteChoice(voteChoiceId, testUpdateData)
		require.NoError(t, err)
		mockVoteChoiceRepo.AssertExpectations(t)
	})

	t.Run("VoteChoiceDoesNotExist", func(t *testing.T) {
		mockVoteChoiceRepo := new(repository_test.VoteChoiceRepositoryMock)
		mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
		repository.VoteChoiceRepositoryInstance = mockVoteChoiceRepo
		repository.VoteLogRepositoryInstance = mockVoteLogRepo
		mockVoteChoiceRepo.On("GetSingleVoteChoice", voteChoiceId).Return(nil, nil)
		err := EditVoteChoice(voteChoiceId, testUpdateData)
		assert.Error(t, err)
	})

	t.Run("UpdateToDuplicateName", func(t *testing.T) {
		mockVoteChoiceRepo := new(repository_test.VoteChoiceRepositoryMock)
		mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
		repository.VoteChoiceRepositoryInstance = mockVoteChoiceRepo
		repository.VoteLogRepositoryInstance = mockVoteLogRepo
		mockVoteChoiceRepo.On("GetSingleVoteChoice", voteChoiceId).Return(&testVoteChoiceData, nil)
		mockVoteLogRepo.On("CountVoteLogByVoteId", voteChoiceId).Return(0, nil)
		mockVoteChoiceRepo.On("UpdateVoteChoice", voteChoiceId, testUpdateData).Return(mongo.WriteException{
			WriteErrors: []mongo.WriteError{{Code: 11000}},
		})

		err := EditVoteChoice(voteChoiceId, testUpdateData)

		assert.Error(t, err)
		assert.IsType(t, &response.ErrorResponse{}, err)
	})

	t.Run("VoteChoiceAlreadyHasScore", func(t *testing.T) {
		mockVoteChoiceRepo := new(repository_test.VoteChoiceRepositoryMock)
		mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
		repository.VoteChoiceRepositoryInstance = mockVoteChoiceRepo
		repository.VoteLogRepositoryInstance = mockVoteLogRepo
		mockVoteChoiceRepo.On("GetSingleVoteChoice", voteChoiceId).Return(&testVoteChoiceData, nil)
		mockVoteLogRepo.On("CountVoteLogByVoteId", voteChoiceId).Return(1, nil)
		err := EditVoteChoice(voteChoiceId, testUpdateData)

		assert.Error(t, err)
		assert.IsType(t, &response.ErrorResponse{}, err)
	})
}

func TestDeleteVoteChoice(t *testing.T) {

	voteChoiceObjectId := primitive.NewObjectID()
	voteChoiceId := voteChoiceObjectId.Hex()
	testVoteChoiceData := model.VoteChoice{
		ID:          voteChoiceObjectId,
		Name:        "firstname",
		Description: "for test only",
	}

	t.Run("Success", func(t *testing.T) {
		mockVoteChoiceRepo := new(repository_test.VoteChoiceRepositoryMock)
		mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
		repository.VoteChoiceRepositoryInstance = mockVoteChoiceRepo
		repository.VoteLogRepositoryInstance = mockVoteLogRepo
		mockVoteChoiceRepo.On("GetSingleVoteChoice", voteChoiceId).Return(&testVoteChoiceData, nil)
		mockVoteLogRepo.On("CountVoteLogByVoteId", voteChoiceId).Return(0, nil)
		mockVoteChoiceRepo.On("DeleteVoteChoice", voteChoiceId).Return(nil)
		err := DeleteVoteChoice(voteChoiceId)
		require.NoError(t, err)
		mockVoteChoiceRepo.AssertExpectations(t)
	})

	t.Run("VoteChoiceDoesNotExist", func(t *testing.T) {
		mockVoteChoiceRepo := new(repository_test.VoteChoiceRepositoryMock)
		repository.VoteChoiceRepositoryInstance = mockVoteChoiceRepo
		mockVoteChoiceRepo.On("GetSingleVoteChoice", voteChoiceId).Return(nil, nil)
		err := DeleteVoteChoice(voteChoiceId)
		assert.Error(t, err)
	})

	t.Run("VoteChoiceAlreadyHasScore", func(t *testing.T) {
		mockVoteChoiceRepo := new(repository_test.VoteChoiceRepositoryMock)
		mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
		repository.VoteChoiceRepositoryInstance = mockVoteChoiceRepo
		repository.VoteLogRepositoryInstance = mockVoteLogRepo
		mockVoteChoiceRepo.On("GetSingleVoteChoice", voteChoiceId).Return(&testVoteChoiceData, nil)
		mockVoteLogRepo.On("CountVoteLogByVoteId", voteChoiceId).Return(1, nil)
		mockVoteChoiceRepo.On("DeleteVoteChoice", voteChoiceId).Return(nil)
		err := DeleteVoteChoice(voteChoiceId)

		assert.Error(t, err)
		assert.Equal(t, "cannot delete vote choice that already have score", err.Error())
	})
}

func TestVoteFor(t *testing.T) {

	testUserObjectId := primitive.NewObjectID()
	testUserId := testUserObjectId.Hex()
	testUserInfo := model.User{
		ID:   testUserObjectId,
		Name: "Test User 1",
	}
	voteChoiceObjectId := primitive.NewObjectID()
	voteChoiceId := voteChoiceObjectId.Hex()
	testVoteChoiceData := model.VoteChoice{
		ID:          voteChoiceObjectId,
		Name:        "firstname",
		Description: "for test only",
	}

	t.Run("Success", func(t *testing.T) {
		mockVoteChoiceRepo := new(repository_test.VoteChoiceRepositoryMock)
		mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
		mockUserRepo := new(repository_test.UserRepositoryMock)
		repository.VoteChoiceRepositoryInstance = mockVoteChoiceRepo
		repository.VoteLogRepositoryInstance = mockVoteLogRepo
		repository.UserRepositoryInstance = mockUserRepo
		mockVoteChoiceRepo.On("GetSingleVoteChoice", voteChoiceId).Return(&testVoteChoiceData, nil)
		mockUserRepo.On("GetUser", testUserId).Return(&testUserInfo, nil)
		mockVoteLogRepo.On("GetVoteLogByUserId", testUserId).Return(nil, nil)
		mockVoteLogRepo.On("InsertVoteLog", model.VoteLog{VoteId: voteChoiceId, VoterUserId: testUserId}).Return(&mongo.InsertOneResult{}, nil)
		err := VoteFor(testUserId, voteChoiceId)
		require.NoError(t, err)
		mockVoteChoiceRepo.AssertExpectations(t)
	})

	t.Run("VoteChoiceDoesNotExist", func(t *testing.T) {
		mockVoteChoiceRepo := new(repository_test.VoteChoiceRepositoryMock)
		mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
		mockUserRepo := new(repository_test.UserRepositoryMock)
		repository.VoteChoiceRepositoryInstance = mockVoteChoiceRepo
		repository.VoteLogRepositoryInstance = mockVoteLogRepo
		repository.UserRepositoryInstance = mockUserRepo
		mockVoteChoiceRepo.On("GetSingleVoteChoice", voteChoiceId).Return(nil, nil)
		err := VoteFor(testUserId, voteChoiceId)
		assert.Error(t, err)
	})

	t.Run("UserDoesNotExist", func(t *testing.T) {
		mockVoteChoiceRepo := new(repository_test.VoteChoiceRepositoryMock)
		mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
		mockUserRepo := new(repository_test.UserRepositoryMock)
		repository.VoteChoiceRepositoryInstance = mockVoteChoiceRepo
		repository.VoteLogRepositoryInstance = mockVoteLogRepo
		repository.UserRepositoryInstance = mockUserRepo
		mockVoteChoiceRepo.On("GetSingleVoteChoice", voteChoiceId).Return(&testVoteChoiceData, nil)
		mockUserRepo.On("GetUser", testUserId).Return(nil, errors.New("user not found"))
		err := VoteFor(testUserId, voteChoiceId)
		assert.Error(t, err)
	})

	t.Run("UserHaveAlreadyVote", func(t *testing.T) {
		mockVoteChoiceRepo := new(repository_test.VoteChoiceRepositoryMock)
		mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
		mockUserRepo := new(repository_test.UserRepositoryMock)
		repository.VoteChoiceRepositoryInstance = mockVoteChoiceRepo
		repository.VoteLogRepositoryInstance = mockVoteLogRepo
		repository.UserRepositoryInstance = mockUserRepo
		mockVoteChoiceRepo.On("GetSingleVoteChoice", voteChoiceId).Return(&testVoteChoiceData, nil)
		mockUserRepo.On("GetUser", testUserId).Return(&testUserInfo, nil)
		mockVoteLogRepo.On("GetVoteLogByUserId", testUserId).Return(&model.VoteLog{}, nil)
		err := VoteFor(testUserId, voteChoiceId)
		assert.Error(t, err)
	})

}

func TestDeleteAllVote(t *testing.T) {
	t.Run("Success", func(t *testing.T) {
		mockVoteChoiceRepo := new(repository_test.VoteChoiceRepositoryMock)
		mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
		repository.VoteChoiceRepositoryInstance = mockVoteChoiceRepo
		repository.VoteLogRepositoryInstance = mockVoteLogRepo
		mockVoteChoiceRepo.On("DeleteAllVoteChoice").Return(int64(1), nil)
		mockVoteLogRepo.On("DeleteAllVoteLogs").Return(int64(1), nil)
		err := DeleteAllVote()
		require.NoError(t, err)
		mockVoteChoiceRepo.AssertExpectations(t)
		mockVoteLogRepo.AssertExpectations(t)
	})

	t.Run("FailToDeleteVoteChoices", func(t *testing.T) {
		mockVoteChoiceRepo := new(repository_test.VoteChoiceRepositoryMock)
		mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
		repository.VoteChoiceRepositoryInstance = mockVoteChoiceRepo
		repository.VoteLogRepositoryInstance = mockVoteLogRepo
		mockVoteChoiceRepo.On("DeleteAllVoteChoice").Return(int64(0), errors.New("failure deleting vote choices"))
		err := DeleteAllVote()
		assert.Error(t, err)
		assert.IsType(t, &response.ErrorResponse{}, err)
		mockVoteChoiceRepo.AssertExpectations(t)
	})

	t.Run("FailToDeleteVoteLogs", func(t *testing.T) {
		mockVoteChoiceRepo := new(repository_test.VoteChoiceRepositoryMock)
		mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
		repository.VoteChoiceRepositoryInstance = mockVoteChoiceRepo
		repository.VoteLogRepositoryInstance = mockVoteLogRepo
		mockVoteChoiceRepo.On("DeleteAllVoteChoice").Return(int64(1), nil)
		mockVoteLogRepo.On("DeleteAllVoteLogs").Return(int64(0), errors.New("failure deleting vote logs"))
		err := DeleteAllVote()
		assert.Error(t, err)
		assert.IsType(t, &response.ErrorResponse{}, err)
		mockVoteLogRepo.AssertExpectations(t)
	})
}

func TestDeleteVoteScore(t *testing.T) {

	t.Run("Success", func(t *testing.T) {
		mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
		repository.VoteLogRepositoryInstance = mockVoteLogRepo
		mockVoteLogRepo.On("DeleteAllVoteLogs").Return(int64(1), nil)

		err := DeleteVoteScore()

		require.NoError(t, err)
		mockVoteLogRepo.AssertExpectations(t)
	})

	t.Run("FailToDeleteVoteLogs", func(t *testing.T) {
		mockVoteLogRepo := new(repository_test.VoteLogRepositoryMock)
		repository.VoteLogRepositoryInstance = mockVoteLogRepo
		mockVoteLogRepo.On("DeleteAllVoteLogs").Return(int64(0), errors.New("failure deleting vote logs"))

		err := DeleteVoteScore()

		assert.Error(t, err)
		assert.IsType(t, &response.ErrorResponse{}, err)
		mockVoteLogRepo.AssertExpectations(t)
	})
}
