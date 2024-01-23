package route

import (
	"github.com/gin-gonic/gin"
	"github.com/tanaponpiti/voter/voter_server/controller"
	"github.com/tanaponpiti/voter/voter_server/service"
)

func RegisterAuthRoutes(rg *gin.RouterGroup) {
	voteChoiceGroup := rg.Group("/auth")
	voteChoiceGroup.GET("/me", service.AuthMiddleware(), controller.Me)
	voteChoiceGroup.POST("/login", controller.Login)
	voteChoiceGroup.POST("/logout", controller.Logout)
}
