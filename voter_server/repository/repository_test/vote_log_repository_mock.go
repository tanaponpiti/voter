package repository_test

import (
	"github.com/stretchr/testify/mock"
	"github.com/tanaponpiti/voter/voter_server/model"
	"go.mongodb.org/mongo-driver/mongo"
)

type VoteLogRepositoryMock struct {
	mock.Mock
}

func (m *VoteLogRepositoryMock) EnsureVoteLogIndex() error {
	args := m.Called()
	return args.Error(0)
}

func (m *VoteLogRepositoryMock) InsertVoteLog(vc model.VoteLog) (*mongo.InsertOneResult, error) {
	args := m.Called(vc)
	return args.Get(0).(*mongo.InsertOneResult), args.Error(1)
}

func (m *VoteLogRepositoryMock) GetAllVoteLogs() ([]model.VoteLog, error) {
	args := m.Called()
	return args.Get(0).([]model.VoteLog), args.Error(1)
}

func (m *VoteLogRepositoryMock) GetVoteLogByUserId(userId string) (*model.VoteLog, error) {
	args := m.Called(userId)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*model.VoteLog), args.Error(1)
}

func (m *VoteLogRepositoryMock) CountVoteLogByVoteId(voteId string) (int, error) {
	args := m.Called(voteId)
	return args.Get(0).(int), args.Error(1)
}

func (m *VoteLogRepositoryMock) DeleteAllVoteLogs() (int64, error) {
	args := m.Called()
	return args.Get(0).(int64), args.Error(1)
}

func (m *VoteLogRepositoryMock) AggregateVoteScores() ([]model.VoteScoreSummary, error) {
	args := m.Called()
	return args.Get(0).([]model.VoteScoreSummary), args.Error(1)
}
