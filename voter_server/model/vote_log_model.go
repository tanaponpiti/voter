package model

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
	"time"
)

const VoteLogCollectionName = "vote_log"

type VoteLog struct {
	ID          primitive.ObjectID `bson:"_id,omitempty"`
	VoteId      string             `bson:"vote_id" validate:"required"`
	VoterUserId string             `bson:"voter_user_id" validate:"required"`
	CreatedAt   time.Time          `bson:"created_at"`
	UpdatedAt   time.Time          `bson:"updated_at"`
}

type VoteScoreSummary struct {
	VoteId    string `bson:"vote_id"`
	VoteScore int    `bson:"vote_score"`
}
