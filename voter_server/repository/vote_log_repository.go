package repository

import (
	"context"
	"errors"
	"github.com/tanaponpiti/voter/voter_server/config"
	"github.com/tanaponpiti/voter/voter_server/database"
	"github.com/tanaponpiti/voter/voter_server/model"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"time"
)

var VoteLogRepositoryInstance *VoteLogRepository

type VoteLogRepository struct {
	collection *mongo.Collection
}

func NewVoteLogRepository() *VoteLogRepository {
	collection := database.MongoClient.Database(config.MongoDBName()).Collection(model.VoteLogCollectionName)
	return &VoteLogRepository{
		collection: collection,
	}
}

func InitVoteLogRepository() error {
	VoteLogRepositoryInstance = NewVoteLogRepository()
	err := VoteLogRepositoryInstance.EnsureVoteLogIndex()
	return err
}

func (r *VoteLogRepository) EnsureVoteLogIndex() error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	opts := options.CreateIndexes().SetMaxTime(10 * time.Second)
	indexModel := mongo.IndexModel{
		Keys:    bson.M{"voter_user_id": 1}, // index in ascending order
		Options: options.Index().SetUnique(true),
	}

	_, err := r.collection.Indexes().CreateOne(ctx, indexModel, opts)
	if err != nil {
		return err
	}

	return nil
}

func (r *VoteLogRepository) InsertVoteLog(vc model.VoteLog) (*mongo.InsertOneResult, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	vc.CreatedAt = time.Now()
	vc.UpdatedAt = time.Now()
	result, err := r.collection.InsertOne(ctx, vc)
	if err != nil {
		return nil, err
	}
	return result, nil
}

func (r *VoteLogRepository) GetAllVoteLogs() ([]model.VoteLog, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	var voteLogs []model.VoteLog
	cursor, err := r.collection.Find(ctx, bson.M{})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)
	for cursor.Next(ctx) {
		var voteLog model.VoteLog
		if err = cursor.Decode(&voteLog); err != nil {
			return nil, err
		}
		voteLogs = append(voteLogs, voteLog)
	}
	if err := cursor.Err(); err != nil {
		return nil, err
	}
	return voteLogs, nil
}

func (r *VoteLogRepository) GetVoteLogByUserId(userId string) (*model.VoteLog, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	filter := bson.M{"voter_user_id": userId}
	var voteLog model.VoteLog
	err := r.collection.FindOne(ctx, filter).Decode(&voteLog)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, nil
		}
		return nil, err
	}
	return &voteLog, nil
}

func (r *VoteLogRepository) CountVoteLogByVoteId(voteId string) (int, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Creating a filter to count only the documents that have the matching voteId.
	filter := bson.M{"vote_id": voteId}

	// Counting the documents matching the filter.
	count, err := r.collection.CountDocuments(ctx, filter)
	if err != nil {
		return 0, err
	}

	return int(count), nil
}

func (r *VoteLogRepository) DeleteAllVoteLogs() (int64, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	result, err := r.collection.DeleteMany(ctx, bson.M{})
	if err != nil {
		return 0, err
	}
	return result.DeletedCount, nil
}

func (r *VoteLogRepository) AggregateVoteScores() ([]model.VoteScoreSummary, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	pipeline := mongo.Pipeline{
		bson.D{
			{"$group", bson.D{
				{"_id", "$vote_id"},
				{"vote_score", bson.D{{"$sum", 1}}},
			}},
		},
		bson.D{
			{"$project", bson.D{
				{"_id", 0},
				{"vote_id", "$_id"},
				{"vote_score", 1},
			}},
		},
	}
	cursor, err := r.collection.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)
	var results []model.VoteScoreSummary
	for cursor.Next(ctx) {
		var summary model.VoteScoreSummary
		if err := cursor.Decode(&summary); err != nil {
			return nil, err
		}
		results = append(results, summary)
	}
	if err := cursor.Err(); err != nil {
		return nil, err
	}
	return results, nil
}
