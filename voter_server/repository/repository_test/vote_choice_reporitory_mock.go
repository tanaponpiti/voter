package repository_test

import (
	"github.com/stretchr/testify/mock"
	"github.com/tanaponpiti/voter/voter_server/model"
	"go.mongodb.org/mongo-driver/mongo"
)

type VoteChoiceRepositoryMock struct {
	mock.Mock
}

func (m *VoteChoiceRepositoryMock) EnsureVoteChoiceIndex() error {
	args := m.Called()
	return args.Error(0)
}

func (m *VoteChoiceRepositoryMock) InsertVoteChoice(vc model.VoteChoiceInsertData) (*mongo.InsertOneResult, error) {
	args := m.Called(vc)
	return args.Get(0).(*mongo.InsertOneResult), args.Error(1)
}

func (m *VoteChoiceRepositoryMock) GetAllVoteChoices() ([]model.VoteChoice, error) {
	args := m.Called()
	return args.Get(0).([]model.VoteChoice), args.Error(1)
}

func (m *VoteChoiceRepositoryMock) GetSingleVoteChoice(id string) (*model.VoteChoice, error) {
	args := m.Called(id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*model.VoteChoice), args.Error(1)
}

func (m *VoteChoiceRepositoryMock) GetVoteChoicesPage(pageSize int, pageNum int, name string, description string) ([]model.VoteChoice, int64, error) {
	args := m.Called(pageSize, pageNum, name, description)
	return args.Get(0).([]model.VoteChoice), args.Get(1).(int64), args.Error(2)
}

func (m *VoteChoiceRepositoryMock) UpdateVoteChoice(id string, updateData model.VoteChoiceUpdateData) error {
	args := m.Called(id, updateData)
	return args.Error(0)
}

func (m *VoteChoiceRepositoryMock) DeleteVoteChoice(id string) error {
	args := m.Called(id)
	return args.Error(0)
}

func (m *VoteChoiceRepositoryMock) DeleteAllVoteChoice() (int64, error) {
	args := m.Called()
	return args.Get(0).(int64), args.Error(1)
}
