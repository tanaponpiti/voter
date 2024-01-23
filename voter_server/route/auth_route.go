package route

import (
	"github.com/gin-gonic/gin"
	"github.com/tanaponpiti/voter/voter_server/controller"
)

func RegisterAuthRoutes(rg *gin.RouterGroup) {
	voteChoiceGroup := rg.Group("/auth")
	voteChoiceGroup.GET("/me", controller.Me)
	voteChoiceGroup.POST("/login", controller.Login)
	voteChoiceGroup.POST("/logout", controller.Logout)
}
