package model

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
	"time"
)

const TokenCollectionName = "token"

type Token struct {
	ID        primitive.ObjectID `bson:"_id,omitempty"`
	UserId    string             `bson:"user_id" validate:"required"`
	Token     string             `bson:"token" validate:"required"`
	CreatedAt time.Time          `bson:"created_at"`
}
