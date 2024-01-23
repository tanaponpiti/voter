package route

import (
	"github.com/gin-gonic/gin"
	"github.com/tanaponpiti/voter/voter_server/controller"
)

func RegisterVoteChoiceRoutes(rg *gin.RouterGroup) {
	voteChoiceGroup := rg.Group("/vote-choice")
	voteChoiceGroup.GET("/", controller.GetAllVoteChoices)
	voteChoiceGroup.GET("/:voteChoiceId", controller.GetSingleVoteChoice)
	voteChoiceGroup.PUT("/:voteChoiceId", controller.UpdateVoteChoice)
	voteChoiceGroup.DELETE("/:voteChoiceId", controller.DeleteVoteChoice)
	voteChoiceGroup.POST("/:voteChoiceId/vote", controller.Vote)
}
