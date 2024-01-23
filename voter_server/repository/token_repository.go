package repository

import (
	"context"
	"github.com/tanaponpiti/voter/voter_server/config"
	"github.com/tanaponpiti/voter/voter_server/database"
	"github.com/tanaponpiti/voter/voter_server/model"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"time"
)

var TokenRepositoryInstance *TokenRepository

type TokenRepository struct {
	collection *mongo.Collection
}

func NewTokenRepository() *TokenRepository {
	collection := database.MongoClient.Database(config.MongoDBName()).Collection(model.TokenCollectionName)
	return &TokenRepository{
		collection: collection,
	}
}

func InitTokenRepository() error {
	TokenRepositoryInstance = NewTokenRepository()
	err := TokenRepositoryInstance.EnsureTokenIndex()
	return err
}

func (r *TokenRepository) EnsureTokenIndex() error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	opts := options.CreateIndexes().SetMaxTime(10 * time.Second)
	indexModel := mongo.IndexModel{
		Keys: bson.M{"token": 1}, // index in ascending order
		Options: options.Index().SetUnique(true).SetCollation(&options.Collation{
			Locale:   "en",
			Strength: 2, // level 2 means case-insensitive
		}),
	}

	_, err := r.collection.Indexes().CreateOne(ctx, indexModel, opts)
	if err != nil {
		return err
	}

	return nil
}

func (r *TokenRepository) GetSingleToken(id string) (*model.Token, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	var token model.Token
	objectId, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return nil, err
	}
	err = r.collection.FindOne(ctx, bson.M{"_id": objectId}).Decode(&token)
	if err != nil {
		return nil, err
	}
	return &token, nil
}

func (r *TokenRepository) DeleteToken(id string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	objectId, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return err
	}
	_, err = r.collection.DeleteOne(ctx, bson.M{"_id": objectId})
	if err != nil {
		return err
	}
	return nil
}

func (r *TokenRepository) DeleteTokenByToken(token string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// Use the token string to delete the document
	_, err := r.collection.DeleteOne(ctx, bson.M{"token": token})
	if err != nil {
		return err
	}

	return nil
}

func (r *TokenRepository) InsertToken(jwtToken string, userId string) (*mongo.InsertOneResult, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	token := model.Token{
		UserId:    userId,
		Token:     jwtToken,
		CreatedAt: time.Now(),
	}
	result, err := r.collection.InsertOne(ctx, token)
	if err != nil {
		return nil, err
	}
	return result, nil
}