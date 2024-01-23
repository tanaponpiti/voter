package config

import (
	"github.com/joho/godotenv"
	"log"
	"os"
	"strconv"
)

func Init() (err error) {
	err = godotenv.Load()
	if err != nil {
		return err
	}
	return nil
}

func GetEnvVariable(key string) string {
	value := os.Getenv(key)
	if value == "" {
		log.Println("Unable to find " + key + " key")
	}
	return value
}

func MongoURI() string {
	return GetEnvVariable("MONGO_URI")
}

func MongoDBName() string {
	return GetEnvVariable("MONGO_DB_NAME")
}

func JWTSecret() string { return GetEnvVariable("JWT_SECRET") }

func TokenExpireHour() int {
	var expireHour = GetEnvVariable("TOKEN_EXPIRE_HOUR")
	if expireHour != "" {
		expireNum, err := strconv.Atoi(expireHour)
		if err != nil {
			expireNum = 24
		}
		return expireNum
	} else {
		return 24
	}
}
