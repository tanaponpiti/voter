package controller

import (
	"github.com/gin-gonic/gin"
	"github.com/tanaponpiti/voter/voter_server/response"
	"github.com/tanaponpiti/voter/voter_server/service"
	"net/http"
)

func Me(c *gin.Context) {
	userId, exist := c.Get("userId")
	if !exist {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}
	userIdStr, ok := userId.(string)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}
	user, err := service.GetUserInfoFromId(userIdStr)
	complete := response.HandleErrorResponse(err, c)
	if complete {
		return
	}
	c.JSON(http.StatusOK, user)
	return
}

type LoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

func Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}
	username := req.Username
	password := req.Password
	token, err := service.Login(username, password)
	complete := response.HandleErrorResponse(err, c)
	if complete {
		return
	}
	c.JSON(http.StatusOK, gin.H{"token": token})
}

func Logout(c *gin.Context) {
	authHeader := c.GetHeader("Authorization")
	if len(authHeader) <= 7 || authHeader[:7] != "Bearer " {
		c.JSON(http.StatusBadRequest, gin.H{"error": "unauthorized"})
		return
	}
	token := authHeader[7:]

	err := service.Logout(token)
	complete := response.HandleErrorResponse(err, c)
	if complete {
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Successfully logged out"})
}
