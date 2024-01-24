package response

import (
	"errors"
	"fmt"
	"github.com/gin-gonic/gin"
	"net/http"
)

type ErrorResponse struct {
	Msg        string // error message
	HTTPStatus int    // HTTP status code
}

func (e *ErrorResponse) Error() string {
	return fmt.Sprintf("status %d: %v", e.HTTPStatus, e.Msg)
}

func NewErrorResponse(msg string, httpStatus int) error {
	return &ErrorResponse{
		Msg:        msg,
		HTTPStatus: httpStatus,
	}
}

func HandleErrorResponse(err error, c *gin.Context) (complete bool) {
	if err != nil {
		var errorResponse *ErrorResponse
		if errors.As(err, &errorResponse) {
			c.JSON(errorResponse.HTTPStatus, gin.H{"error": errorResponse.Msg})
			return true
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "unknown error"})
			return true
		}
	} else {
		return false
	}
}
