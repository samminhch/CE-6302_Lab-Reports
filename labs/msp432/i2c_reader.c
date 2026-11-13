#include "i2c_common.h"
static volatile uint8_t data;

static void init_i2c() {
  // SDA_PIN and SCK_PIN get {SEL1,SEL0}=Primary Module Function (e.g. I2C)
  P1->SEL0 |= SDA_PIN | SCK_PIN;
  P1->SEL1 &= ~(SDA_PIN | SCK_PIN);

  // SW reset while configuring I2C
  EUSCI_B0->CTLW0  = EUSCI_B_CTLW0_SWRST;
  EUSCI_B0->CTLW0 |= EUSCI_B_CTLW0_UCSSEL_3 // SMCLK (6 MHz)
                     | EUSCI_B_CTLW0_MODE_3 // I2C Mode
                     | EUSCI_B_CTLW0_MST;   // Master Mode

  // Baud Rate = SMCLK / 60 = 100 kHz
  EUSCI_B0->BRW = 60;

  // Set the I2C Slave Address
  EUSCI_B0->I2CSA = RTC_SLAVE_ADDR;

  // Auto-Stop Mode
  EUSCI_B0->CTLW1 = EUSCI_B_CTLW1_ASTP_2;
  EUSCI_B0->TBCNT = 1; // STOP after transmitter 1 byte

  // Release SW reset
  EUSCI_B0->CTLW0 &= ~EUSCI_B_CTLW0_SWRST;
}

int main() {
  WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD; // Stop the WatchDog Timer

  init_i2c();

  EUSCI_B0->IE |= EUSCI_B_IE_TXIE0 | EUSCI_B_IE_RXIE0;
  NVIC_EnableIRQ(EUSCIB0_IRQn);
  __enable_irq();

  while (1) {
    // Trasmit data
    // Set TR, TXSTT and do the flag polling
    EUSCI_B0->CTLW0 |= EUSCI_B_CTLW0_TR       // Set Transmitter Mode
                       | EUSCI_B_CTLW0_TXSTT; // Generate START condition

    while (!(EUSCI_B0->IFG & EUSCI_B_IFG_STPIFG));
    EUSCI_B0->IFG &= ~EUSCI_B_IFG_STPIFG;
    for (size_t i = 0; i < 100; i++) { __NOP(); }

    // Receive data
    //  Clear TR, set TXSTT and do the flag polling
    EUSCI_B0->CTLW0 &= ~EUSCI_B_CTLW0_TR;
    EUSCI_B0->CTLW0 |= EUSCI_B_CTLW0_TXSTT;

    while (!(EUSCI_B0->IFG & EUSCI_B_IFG_STPIFG));
    EUSCI_B0->IFG &= ~EUSCI_B_IFG_STPIFG;
    for (size_t i = 0; i < 100; i++) { __NOP(); }
  }
  return 0;
}

void EUSCIB0_IRQHandler(void) {
  switch (EUSCI_B0->IV) {
    // Slave 0 Data Received
    case 0x16: {
      data = EUSCI_B0->RXBUF;
      break;
    }

    // Slave 0 Transmit Buffer Empty
    case 0x18: {
      EUSCI_B0->TXBUF = RTC_REG_ADDR;
      break;
    }

    default:
      break;
  }
}
