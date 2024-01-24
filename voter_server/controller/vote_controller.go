package controller

import (
	"github.com/gin-gonic/gin"
	"github.com/tanaponpiti/voter/voter_server/model"
	"github.com/tanaponpiti/voter/voter_server/response"
	"github.com/tanaponpiti/voter/voter_server/service"
	"net/http"
)

func GetAllVoteChoices(c *gin.Context) {
	vote, err := service.GetAllVote()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "unable to get all vote choice with score"})
		return
	}
	c.JSON(http.StatusOK, vote)
	return
}

func CreateVoteChoices(c *gin.Context) {
	var insertData model.VoteChoiceInsertData
	if err := c.ShouldBindJSON(&insertData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	err := service.CreateVoteChoice(insertData)
	complete := response.HandleErrorResponse(err, c)
	if complete {
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Vote choice created successfully"})
}

func UpdateVoteChoice(c *gin.Context) {
	voteChoiceId := c.Param("voteChoiceId")
	if voteChoiceId == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "voteChoiceId is required"})
		return
	}
	var updateData model.VoteChoiceUpdateData
	if err := c.ShouldBindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	err := service.EditVoteChoice(voteChoiceId, updateData)
	complete := response.HandleErrorResponse(err, c)
	if complete {
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Vote choice updated successfully"})
}

func DeleteVoteChoice(c *gin.Context) {
	voteChoiceId := c.Param("voteChoiceId")
	if voteChoiceId == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "voteChoiceId is required"})
		return
	}
	err := service.DeleteVoteChoice(voteChoiceId)
	complete := response.HandleErrorResponse(err, c)
	if complete {
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Vote choice updated successfully"})
}

func Vote(c *gin.Context) {
	voteChoiceId := c.Param("voteChoiceId")
	if voteChoiceId == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "voteChoiceId is required"})
		return
	}
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
	err := service.VoteFor(userIdStr, voteChoiceId)
	complete := response.HandleErrorResponse(err, c)
	if complete {
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Vote successfully"})
}
