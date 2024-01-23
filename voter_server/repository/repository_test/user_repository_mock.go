package repository_test

import (
	"github.com/stretchr/testify/mock"
	"github.com/tanaponpiti/voter/voter_server/model"
	"go.mongodb.org/mongo-driver/mongo"
)

type UserRepositoryMock struct {
	mock.Mock
}

func (m *UserRepositoryMock) EnsureUserIndex() error {
	args := m.Called()
	return args.Error(0)
}

func (m *UserRepositoryMock) InsertUser(user model.User) (*mongo.InsertOneResult, error) {
	args := m.Called(user)
	return args.Get(0).(*mongo.InsertOneResult), args.Error(1)
}

func (m *UserRepositoryMock) GetUser(id string) (*model.User, error) {
	args := m.Called(id)
	return args.Get(0).(*model.User), args.Error(1)
}

func (m *UserRepositoryMock) GetUserByUsername(username string) (*model.User, error) {
	args := m.Called(username)
	return args.Get(0).(*model.User), args.Error(1)
}

func (m *UserRepositoryMock) UpdateUser(id string, updateData model.User) error {
	args := m.Called(id, updateData)
	return args.Error(0)
}

func (m *UserRepositoryMock) DeleteUser(id string) error {
	args := m.Called(id)
	return args.Error(0)
}

func (m *UserRepositoryMock) EnsureTestUsers() error {
	args := m.Called()
	return args.Error(0)
}
