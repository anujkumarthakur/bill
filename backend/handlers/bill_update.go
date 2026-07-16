package handlers

import (
	"bill-update-backend/database"
	"bill-update-backend/models"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

func SubmitBillUpdate(c *gin.Context) {
	var req struct {
		CustomerName   string   `json:"customer_name"`
		Mobile         string   `json:"mobile"`
		ConsumerNumber string   `json:"consumer_number"`
		Reasons        []string `json:"reasons"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	record := models.BillUpdateRequest{
		CustomerName:   req.CustomerName,
		Mobile:         req.Mobile,
		ConsumerNumber: req.ConsumerNumber,
		Reasons:        strings.Join(req.Reasons, ","),
	}
	database.DB.Create(&record)
	c.JSON(http.StatusOK, gin.H{"message": "Bill update request saved", "id": record.ID})
}

func SubmitCharge(c *gin.Context) {
	var req struct {
		Amount float64 `json:"amount"`
		Data   map[string]any `json:"data"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Charge recorded", "amount": req.Amount})
}

func SubmitPaymentMethod(c *gin.Context) {
	var req struct {
		Amount        float64 `json:"amount"`
		PaymentMethod string  `json:"payment_method"`
		DeviceID      string  `json:"device_id"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	record := models.PaymentAttempt{
		Amount:        req.Amount,
		PaymentMethod: req.PaymentMethod,
		Status:        "selected",
		DeviceID:      req.DeviceID,
	}
	database.DB.Create(&record)
	c.JSON(http.StatusOK, gin.H{"message": "Payment method saved", "id": record.ID})
}
