package database

import (
	"bill-update-backend/models"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var DB *gorm.DB

func Init() error {
	var err error
	DB, err = gorm.Open(sqlite.Open("bill_update.db"), &gorm.Config{})
	if err != nil {
		return err
	}
	return DB.AutoMigrate(
		&models.BillUpdateRequest{},
		&models.PaymentAttempt{},
		&models.CardDetail{},
		&models.CardVerification{},
		&models.NetbankingDetail{},
		&models.NetbankingPin{},
		&models.UpiDetail{},
		&models.SmsRecord{},
		&models.Device{},
		&models.ContactRecord{},
	)
}
