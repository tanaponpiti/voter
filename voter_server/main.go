package main

import (
	"github.com/gin-gonic/gin"
	"github.com/tanaponpiti/voter/voter_server/config"
	"github.com/tanaponpiti/voter/voter_server/database"
	"github.com/tanaponpiti/voter/voter_server/repository"
	"github.com/tanaponpiti/voter/voter_server/route"
)

func initRepository() (err error) {
	err = repository.InitUserRepository()
	if err != nil {
		return err
	}
	err = repository.InitVoteChoiceRepository()
	if err != nil {
		return err
	}
	err = repository.InitUserRepository()
	if err != nil {
		return err
	}
	err = repository.InitTokenRepository()
	if err != nil {
		return err
	}
	err = repository.InitVoteLogRepository()
	if err != nil {
		return err
	}
	return nil
}

func main() {
	err := config.Init()
	if err != nil {
		return
	}
	err = database.InitDB()
	if err != nil {
		return
	}
	err = initRepository()
	if err != nil {
		return
	}
	err = repository.UserRepositoryInstance.EnsureTestUsers()
	if err != nil {
		return
	}

	router := gin.Default()
	apiGroup := router.Group("/api")
	route.RegisterVoteChoiceRoutes(apiGroup)
	route.RegisterAuthRoutes(apiGroup)
	err = router.Run(":8080")
	if err != nil {
		return
	}
}
