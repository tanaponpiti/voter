package service

import (
	"errors"
	"github.com/dgrijalva/jwt-go"
	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"github.com/tanaponpiti/voter/voter_server/model"
	"github.com/tanaponpiti/voter/voter_server/repository"
	"github.com/tanaponpiti/voter/voter_server/repository/repository_test"
	"github.com/tanaponpiti/voter/voter_server/utility"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
)

func setEnv() {

}

func TestGenerateAndValidateToken(t *testing.T) {
	err := os.Setenv("JWT_SECRET", "ji3ij1nm109aspa")
	assert.Nil(t, err)
	defer os.Unsetenv("JWT_SECRET")
	userID := "testUserID"
	mockTokenRepo := new(repository_test.TokenRepositoryMock)
	repository.TokenRepositoryInstance = mockTokenRepo

	mockTokenRepo.On("InsertToken", mock.AnythingOfType("string"), userID).Return(&mongo.InsertOneResult{}, nil)

	token, err := generateToken(userID)
	assert.Nil(t, err)
	assert.NotEmpty(t, token)

	tokenData, err := validateToken(token)
	assert.Nil(t, err)
	claims, ok := tokenData.Claims.(jwt.MapClaims)
	assert.Equal(t, true, ok)
	err = claims.Valid()
	assert.Nil(t, err)
	assert.Equal(t, "testUserID", claims["id"])

	mockTokenRepo.AssertExpectations(t)
}

func TestGetUserInfoFromId(t *testing.T) {
	// Setup
	mongoID := primitive.NewObjectID()
	userID := mongoID.Hex()
	mockUserRepo := new(repository_test.UserRepositoryMock)
	repository.UserRepositoryInstance = mockUserRepo

	// Expectations
	mockUserRepo.On("GetUser", userID).Return(&model.User{ID: mongoID}, nil)

	// Test
	user, err := GetUserInfoFromId(userID)

	// Assert
	assert.Nil(t, err)
	assert.NotNil(t, user)
	assert.Equal(t, userID, user.ID.Hex())
	mockUserRepo.AssertExpectations(t)
}

func TestLogin(t *testing.T) {
	err := os.Setenv("JWT_SECRET", "ji3ij1nm109aspa")
	assert.Nil(t, err)
	defer os.Unsetenv("JWT_SECRET")
	username := "testUser"
	password := "testPassword"
	mockTokenRepo := new(repository_test.TokenRepositoryMock)
	repository.TokenRepositoryInstance = mockTokenRepo
	mockUserRepo := new(repository_test.UserRepositoryMock)
	repository.UserRepositoryInstance = mockUserRepo
	mongoID := primitive.NewObjectID()
	userID := mongoID.Hex()
	hashedPassword, err := utility.HashPassword(password)
	mockUser := model.User{ID: mongoID, Username: "testUser", Password: hashedPassword}
	assert.Nil(t, err)

	mockUserRepo.On("GetUserByUsername", username).Return(&mockUser, nil)
	mockTokenRepo.On("InsertToken", mock.AnythingOfType("string"), userID).Return(&mongo.InsertOneResult{}, nil)

	// Test
	token, err := Login(username, password)
	assert.Nil(t, err)
	assert.NotEmpty(t, token)

	// Test wrong password
	token, err = Login(username, "wrong_password")
	assert.Empty(t, token)
	assert.NotNil(t, err)

	mockUserRepo.AssertExpectations(t)
}

func TestAuthMiddleware(t *testing.T) {
	err := os.Setenv("JWT_SECRET", "ji3ij1nm109aspa")
	assert.Nil(t, err)
	defer os.Unsetenv("JWT_SECRET")

	r := gin.New()
	r.Use(AuthMiddleware())
	r.GET("/test", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"userId": c.MustGet("userId")})
	})

	// Test case: Valid token
	t.Run("Valid Token", func(t *testing.T) {
		w := httptest.NewRecorder()
		req, _ := http.NewRequest("GET", "/test", nil)
		// Assuming you have a function to generate a valid token for testing
		userID := "testUserID"
		mockTokenRepo := new(repository_test.TokenRepositoryMock)
		repository.TokenRepositoryInstance = mockTokenRepo
		mockTokenRepo.On("InsertToken", mock.AnythingOfType("string"), userID).Return(&mongo.InsertOneResult{}, nil)
		token, err := generateToken(userID)
		mockTokenRepo.On("GetByToken", token).Return(&model.Token{Token: token}, nil)

		assert.Nil(t, err)
		req.Header.Set("Authorization", "Bearer "+token)

		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		// You may want to check the body to see if it contains the correct user ID
		// assert.Contains(t, w.Body.String(), expectedUserID)
	})

	// Test case: Invalid token
	t.Run("Invalid Token", func(t *testing.T) {
		w := httptest.NewRecorder()
		req, _ := http.NewRequest("GET", "/test", nil)
		req.Header.Set("Authorization", "Bearer invalidToken")

		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	// Test case: Missing token
	t.Run("Missing Token", func(t *testing.T) {
		w := httptest.NewRecorder()
		req, _ := http.NewRequest("GET", "/test", nil)

		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})
}

func TestLogout(t *testing.T) {
	// Mock the token repository
	mockTokenRepo := new(repository_test.TokenRepositoryMock)
	repository.TokenRepositoryInstance = mockTokenRepo

	t.Run("Successful Logout", func(t *testing.T) {
		// Setup expectations
		testToken := "testToken"
		mockTokenRepo.On("DeleteTokenByToken", testToken).Return(nil)

		// Call the service function
		err1 := Logout(testToken)

		// Assert expectations
		assert.Nil(t, err1)
		mockTokenRepo.AssertExpectations(t)
	})

	t.Run("Failed Logout", func(t *testing.T) {
		// Setup expectations
		testUnknownToken := "testUnknownToken"
		mockTokenRepo.On("DeleteTokenByToken", testUnknownToken).Return(errors.New("deletion failed"))

		// Call the service function
		err2 := Logout(testUnknownToken)

		// Assert expectations
		assert.NotNil(t, err2)
		assert.Equal(t, "deletion failed", err2.Error())
		mockTokenRepo.AssertExpectations(t)
	})
}
