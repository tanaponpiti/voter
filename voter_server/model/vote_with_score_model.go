package model

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
	"time"
)

type VoteWithScore struct {
	ID          primitive.ObjectID `bson:"_id,omitempty"`
	Name        string             `bson:"name" validate:"required"`
	Description string             `bson:"description"`
	Score       int                `bson:"score"`
	CreatedAt   time.Time          `bson:"created_at"`
	UpdatedAt   time.Time          `bson:"updated_at"`
}