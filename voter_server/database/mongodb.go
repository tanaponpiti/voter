package database

import (
	"context"
	"github.com/tanaponpiti/voter/voter_server/config"
	"log"
	"time"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var MongoClient *mongo.Client

func ConnectMongoDB() (client *mongo.Client, err error) {
	clientOptions := options.Client().ApplyURI(config.MongoURI())
	clientOptions.SetMaxPoolSize(20)
	clientOptions.SetMinPoolSize(5)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	client, err = mongo.Connect(ctx, clientOptions)
	if err != nil {
		return nil, err
	}
	err = client.Ping(ctx, nil)
	if err != nil {
		return nil, err
	}
	log.Println("Connected to MongoDB!")
	return client, nil
}

func InitDB() (err error) {
	db, err := ConnectMongoDB()
	if err != nil {
		return err
	}
	MongoClient = db
	return nil
}
