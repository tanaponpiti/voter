package repository

import (
	"context"
	"fmt"
	"github.com/tanaponpiti/voter/voter_server/config"
	"github.com/tanaponpiti/voter/voter_server/database"
	"github.com/tanaponpiti/voter/voter_server/model"
	"github.com/tanaponpiti/voter/voter_server/utility"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"time"
)

type IUserRepository interface {
	EnsureUserIndex() error
	InsertUser(user model.User) (*mongo.InsertOneResult, error)
	GetUser(id string) (*model.User, error)
	GetUserByUsername(username string) (*model.User, error)
	UpdateUser(id string, updateData model.User) error
	DeleteUser(id string) error
	EnsureTestUsers() error
}

var UserRepositoryInstance IUserRepository

type UserRepository struct {
	collection *mongo.Collection
}

func NewUserRepository() *UserRepository {
	collection := database.MongoClient.Database(config.MongoDBName()).Collection(model.UserCollectionName)
	return &UserRepository{
		collection: collection,
	}
}

func InitUserRepository() error {
	UserRepositoryInstance = NewUserRepository()
	err := UserRepositoryInstance.EnsureUserIndex()
	return err
}

func (r *UserRepository) EnsureUserIndex() error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	opts := options.CreateIndexes().SetMaxTime(10 * time.Second)
	indexModel := mongo.IndexModel{
		Keys: bson.M{"username": 1}, // index in ascending order
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

func (r *UserRepository) InsertUser(user model.User) (*mongo.InsertOneResult, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	hashedPassword, err := utility.HashPassword(user.Password)
	if err != nil {
		return nil, err
	}
	user.Password = hashedPassword
	user.CreatedAt = time.Now()
	user.UpdatedAt = time.Now()

	result, err := r.collection.InsertOne(ctx, user)
	if err != nil {
		return nil, err
	}
	return result, nil
}

func (r *UserRepository) GetUser(id string) (*model.User, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	var user model.User
	objectId, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return nil, err
	}
	err = r.collection.FindOne(ctx, bson.M{"_id": objectId}).Decode(&user)
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetUserByUsername(username string) (*model.User, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var user model.User
	err := r.collection.FindOne(ctx, bson.M{"username": username}).Decode(&user)
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) UpdateUser(id string, updateData model.User) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	objectId, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return err
	}
	update := bson.M{"$set": bson.M{}}
	if updateData.Name != "" {
		update["$set"].(bson.M)["name"] = updateData.Name
	}
	if updateData.Password != "" {
		hashedPassword, err := utility.HashPassword(updateData.Password)
		if err != nil {
			return err
		}
		update["$set"].(bson.M)["password"] = hashedPassword
	}
	if len(update["$set"].(bson.M)) == 0 {
		return nil
	}
	_, err = r.collection.UpdateOne(ctx, bson.M{"_id": objectId}, update)
	if err != nil {
		return err
	}
	return nil
}

func (r *UserRepository) DeleteUser(id string) error {
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

func (r *UserRepository) countUsersByUsernamePattern(pattern string) (int64, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	count, err := r.collection.CountDocuments(ctx, bson.M{"username": bson.M{"$regex": pattern}})
	if err != nil {
		return 0, err
	}
	return count, nil
}

func (r *UserRepository) EnsureTestUsers() error {
	existingCount, err := r.countUsersByUsernamePattern("^testuser[0-9]+$")
	if err != nil {
		return err
	}
	needToCreate := 10 - existingCount
	for i := 1; i <= int(needToCreate); i++ {
		testUser := model.User{
			Name:     fmt.Sprintf("Test User %d", existingCount+int64(i)),
			Username: fmt.Sprintf("testuser%d", existingCount+int64(i)),
			Password: "testpassword",
		}
		_, err := r.InsertUser(testUser)
		if err != nil {
			return err
		}
	}
	return nil
}
