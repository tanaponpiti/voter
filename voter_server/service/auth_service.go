package service

import (
	"errors"
	"fmt"
	"github.com/dgrijalva/jwt-go"
	"github.com/gin-gonic/gin"
	"github.com/tanaponpiti/voter/voter_server/config"
	"github.com/tanaponpiti/voter/voter_server/model"
	"github.com/tanaponpiti/voter/voter_server/repository"
	"github.com/tanaponpiti/voter/voter_server/utility"
	"net/http"
	"strings"
	"time"
)

func generateToken(userID string) (string, error) {
	jwtSecret := []byte(config.JWTSecret())
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"id":  userID,
		"exp": time.Now().Add(time.Hour * time.Duration(config.TokenExpireHour())).Unix(),
	})
	jwtToken, err := token.SignedString(jwtSecret)
	if err != nil {
		return "", err
	}
	_, err = repository.TokenRepositoryInstance.InsertToken(jwtToken, userID)
	if err != nil {
		return "", err
	}
	return jwtToken, nil
}

func validateToken(tokenString string) (*jwt.Token, error) {
	jwtSecret := []byte(config.JWTSecret())
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method")
		}
		return jwtSecret, nil
	})
	if err != nil {
		return nil, err
	}
	return token, nil
}

func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		tokenString, err := GetTokenFromBearerHeader(c)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
			return
		}
		token, err := validateToken(tokenString)
		if token == nil || err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
			return
		}

		if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
			c.Set("userId", claims["id"])
		} else {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
			return
		}

		c.Next()
	}
}

func GetUserInfoFromId(userId string) (user *model.User, err error) {
	user, err = repository.UserRepositoryInstance.GetUser(userId)
	if err != nil {
		return nil, fmt.Errorf("user not found: %v", err)
	}
	return user, nil
}

func Login(username string, password string) (jwtToken string, err error) {
	user, err := repository.UserRepositoryInstance.GetUserByUsername(username)
	if err != nil {
		return "", errors.New("invalid credential")
	}
	if utility.CheckPasswordHash(password, user.Password) {
		return generateToken(user.ID.Hex())
	} else {
		return "", errors.New("invalid credential")
	}
}

func Logout(token string) (err error) {
	return repository.TokenRepositoryInstance.DeleteTokenByToken(token)
}

func GetTokenFromBearerHeader(c *gin.Context) (string, error) {
	authorizationHeader := c.GetHeader("Authorization")
	if authorizationHeader == "" {
		return "", errors.New("no Authorization header provided")
	}
	const bearerSchema = "Bearer "
	if !strings.HasPrefix(authorizationHeader, bearerSchema) {
		return "", errors.New("authorization header format must be 'Bearer {token}'")
	}
	token := strings.TrimPrefix(authorizationHeader, bearerSchema)
	if token == "" {
		return "", errors.New("no token found in Authorization header")
	}
	return token, nil
}
