package repository_test

import (
	"github.com/stretchr/testify/mock"
	"github.com/tanaponpiti/voter/voter_server/model"
	"go.mongodb.org/mongo-driver/mongo"
)

// TokenRepositoryMock is a mock for the ITokenRepository
type TokenRepositoryMock struct {
	mock.Mock
}

// EnsureTokenIndex mocks the EnsureTokenIndex method
func (m *TokenRepositoryMock) EnsureTokenIndex() error {
	args := m.Called()
	return args.Error(0)
}

// GetSingleToken mocks the GetSingleToken method
func (m *TokenRepositoryMock) GetByToken(id string) (*model.Token, error) {
	args := m.Called(id)
	return args.Get(0).(*model.Token), args.Error(1)
}

// DeleteToken mocks the DeleteToken method
func (m *TokenRepositoryMock) DeleteToken(id string) error {
	args := m.Called(id)
	return args.Error(0)
}

// DeleteTokenByToken mocks the DeleteTokenByToken method
func (m *TokenRepositoryMock) DeleteTokenByToken(token string) error {
	args := m.Called(token)
	return args.Error(0)
}

// InsertToken mocks the InsertToken method
func (m *TokenRepositoryMock) InsertToken(jwtToken string, userId string) (*mongo.InsertOneResult, error) {
	args := m.Called(jwtToken, userId)
	return args.Get(0).(*mongo.InsertOneResult), args.Error(1)
}
