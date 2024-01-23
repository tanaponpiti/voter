package controller

import (
	"errors"
	"github.com/gin-gonic/gin"
	"github.com/tanaponpiti/voter/voter_server/model"
	"github.com/tanaponpiti/voter/voter_server/repository"
	"github.com/tanaponpiti/voter/voter_server/service"
	"go.mongodb.org/mongo-driver/mongo"
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
	_, err := repository.VoteChoiceRepositoryInstance.InsertVoteChoice(insertData)
	if err != nil {
		var mongoWriteException mongo.WriteException
		if errors.As(err, &mongoWriteException) {
			for _, err := range mongoWriteException.WriteErrors {
				if err.Code == 11000 { // 11000 is the error code for duplicate key error in MongoDB
					c.JSON(http.StatusConflict, gin.H{"error": "A vote choice with the same name already exists"})
					return
				}
			}
		}
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to create the vote choice"})
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
	if err != nil {
		var mongoWriteException mongo.WriteException
		if errors.As(err, &mongoWriteException) {
			for _, err := range mongoWriteException.WriteErrors {
				if err.Code == 11000 { // 11000 is the error code for duplicate key error in MongoDB
					c.JSON(http.StatusConflict, gin.H{"error": "A vote choice with the same name already exists"})
					return
				}
			}
		}
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to update the vote choice"})
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
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to delete the vote choice"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Vote choice deleted successfully"})
}

func Vote(c *gin.Context) {
	// Handler logic here...
}
