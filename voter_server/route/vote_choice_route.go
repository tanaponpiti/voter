package route

import (
	"github.com/gin-gonic/gin"
	"github.com/tanaponpiti/voter/voter_server/controller"
	"github.com/tanaponpiti/voter/voter_server/service"
)

func RegisterVoteChoiceRoutes(rg *gin.RouterGroup) {
	voteChoiceGroup := rg.Group("/vote", service.AuthMiddleware())
	voteChoiceGroup.GET("/", controller.GetAllVoteChoices)
	voteChoiceGroup.GET("/user", controller.GetUserVote)
	voteChoiceGroup.POST("/", controller.CreateVoteChoices)
	voteChoiceGroup.PUT("/:voteChoiceId", controller.UpdateVoteChoice)
	voteChoiceGroup.DELETE("/:voteChoiceId", controller.DeleteVoteChoice)
	voteChoiceGroup.POST("/:voteChoiceId/vote", controller.Vote)
	voteChoiceGroup.DELETE("/delete-all", controller.DeleteAllVote)
	voteChoiceGroup.DELETE("/delete-vote-score", controller.DeleteVoteScore)
}
