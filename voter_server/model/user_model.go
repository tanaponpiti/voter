package model

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
	"time"
)

const UserCollectionName = "user"

type User struct {
	ID        primitive.ObjectID `bson:"_id,omitempty"`
	Username  string             `bson:"username" validate:"required"`
	Password  string             `bson:"password" validate:"required"`
	Name      string             `bson:"name" validate:"required"`
	CreatedAt time.Time          `bson:"created_at"`
	UpdatedAt time.Time          `bson:"updated_at"`
}
