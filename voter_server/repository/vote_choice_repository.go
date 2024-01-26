package repository

import (
	"context"
	"errors"
	"github.com/tanaponpiti/voter/voter_server/config"
	"github.com/tanaponpiti/voter/voter_server/database"
	"github.com/tanaponpiti/voter/voter_server/model"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"time"
)

type IVoteChoiceRepository interface {
	EnsureVoteChoiceIndex() error
	InsertVoteChoice(vc model.VoteChoiceInsertData) (*mongo.InsertOneResult, error)
	GetAllVoteChoices() ([]model.VoteChoice, error)
	GetSingleVoteChoice(id string) (*model.VoteChoice, error)
	GetVoteChoicesPage(pageSize int, pageNum int, name string, description string) ([]model.VoteChoice, int64, error)
	UpdateVoteChoice(id string, updateData model.VoteChoiceUpdateData) error
	DeleteVoteChoice(id string) error
	DeleteAllVoteChoice() (int64, error)
}

var VoteChoiceRepositoryInstance IVoteChoiceRepository

type VoteChoiceRepository struct {
	collection *mongo.Collection
}

func NewVoteChoiceRepository() *VoteChoiceRepository {
	collection := database.MongoClient.Database(config.MongoDBName()).Collection(model.VoteChoiceCollectionName)
	return &VoteChoiceRepository{
		collection: collection,
	}
}

func InitVoteChoiceRepository() error {
	VoteChoiceRepositoryInstance = NewVoteChoiceRepository()
	err := VoteChoiceRepositoryInstance.EnsureVoteChoiceIndex()
	return err
}

func (r *VoteChoiceRepository) EnsureVoteChoiceIndex() error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	opts := options.CreateIndexes().SetMaxTime(10 * time.Second)
	indexModel := mongo.IndexModel{
		Keys: bson.M{"name": 1}, // index in ascending order
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

func (r *VoteChoiceRepository) InsertVoteChoice(vc model.VoteChoiceInsertData) (*mongo.InsertOneResult, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	currentTime := time.Now()
	choice := model.VoteChoice{
		Name:        vc.Name,
		Description: vc.Description,
		CreatedAt:   currentTime,
		UpdatedAt:   currentTime,
	}
	result, err := r.collection.InsertOne(ctx, choice)
	if err != nil {
		return nil, err
	}
	return result, nil
}

func (r *VoteChoiceRepository) GetAllVoteChoices() ([]model.VoteChoice, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	var voteChoices []model.VoteChoice
	cursor, err := r.collection.Find(ctx, bson.M{})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)
	for cursor.Next(ctx) {
		var voteChoice model.VoteChoice
		if err = cursor.Decode(&voteChoice); err != nil {
			return nil, err
		}
		voteChoices = append(voteChoices, voteChoice)
	}
	if err := cursor.Err(); err != nil {
		return nil, err
	}
	return voteChoices, nil
}

func (r *VoteChoiceRepository) GetSingleVoteChoice(id string) (*model.VoteChoice, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	var voteChoice model.VoteChoice
	objectId, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return nil, err
	}
	err = r.collection.FindOne(ctx, bson.M{"_id": objectId}).Decode(&voteChoice)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, nil
		}
		return nil, err
	}
	return &voteChoice, nil
}

func (r *VoteChoiceRepository) GetVoteChoicesPage(pageSize int, pageNum int, name string, description string) ([]model.VoteChoice, int64, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var voteChoices []model.VoteChoice

	// Calculate the number of documents to skip
	skip := (pageNum - 1) * pageSize

	// Find options for pagination
	findOptions := options.Find().SetSkip(int64(skip)).SetLimit(int64(pageSize))

	// Building the query filter
	queryFilter := bson.M{}
	if name != "" {
		queryFilter["name"] = bson.M{"$regex": primitive.Regex{Pattern: name, Options: "i"}} // case-insensitive
	}
	if description != "" {
		queryFilter["description"] = bson.M{"$regex": primitive.Regex{Pattern: description, Options: "i"}} // case-insensitive
	}

	// Finding multiple documents returns a cursor
	cursor, err := r.collection.Find(ctx, queryFilter, findOptions)
	if err != nil {
		return nil, 0, err
	}
	defer cursor.Close(ctx)

	// Iterate through the cursor
	for cursor.Next(ctx) {
		var voteChoice model.VoteChoice
		err := cursor.Decode(&voteChoice)
		if err != nil {
			return nil, 0, err
		}
		voteChoices = append(voteChoices, voteChoice)
	}
	if err := cursor.Err(); err != nil {
		return nil, 0, err
	}

	// Get the total number of documents in the collection that match the filter
	total, err := r.collection.CountDocuments(ctx, queryFilter)
	if err != nil {
		return nil, 0, err
	}

	return voteChoices, total, nil
}

func (r *VoteChoiceRepository) UpdateVoteChoice(id string, updateData model.VoteChoiceUpdateData) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	objectId, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return err
	}

	update := bson.M{}
	if updateData.Name != nil {
		update["$set"] = bson.M{"name": *updateData.Name}
	}
	if updateData.Description != nil {
		// If $set already initialized, add to it instead of overwriting
		if _, ok := update["$set"]; ok {
			update["$set"].(bson.M)["description"] = *updateData.Description
		} else {
			update["$set"] = bson.M{"description": *updateData.Description}
		}
	}

	if len(update) == 0 {
		return nil
	}

	_, err = r.collection.UpdateOne(ctx, bson.M{"_id": objectId}, update)
	if err != nil {
		return err
	}

	return nil
}

func (r *VoteChoiceRepository) DeleteVoteChoice(id string) error {
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

func (r *VoteChoiceRepository) DeleteAllVoteChoice() (int64, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	result, err := r.collection.DeleteMany(ctx, bson.M{})
	if err != nil {
		return 0, err
	}
	return result.DeletedCount, nil
}
