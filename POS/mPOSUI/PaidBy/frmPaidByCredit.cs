using Microsoft.Reporting.WinForms;
using POS.APP_Data;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace POS
{
    public partial class frmPaidByCredit : Form
    {
        #region Variables
        string shopname = string.Empty;
        string tranno = string.Empty;
        public List<TransactionDetail> DetailList = new List<TransactionDetail>();
       // public List<GiftSystem> GiftList = new List<GiftSystem>();
        public int Discount { get; set; }
        public string transactionParentId { get; set; }
        public int Tax { get; set; }

        public int ExtraDiscount { get; set; }

        public int ExtraTax { get; set; }

        public Boolean isDraft { get; set; }

        public Boolean isDebt { get; set; }

        public string DraftId { get; set; }

        public string DebtId { get; set; }

        public long DebtAmount { get; set; }

        public Boolean IsWholeSale { get; set; }
        public int Frequency { get; set; }

        int paymentType;
        public long GiftDiscountAmt { get; set; }
        public long PrePaidAmount { get; set; }

        public List<Transaction> CreditTransaction { get; set; }

        public List<Transaction> PrePaidTransaction { get; set; }

        private POSEntities entity = new POSEntities();

        private ToolTip tp = new ToolTip();

        private long totalAmount = 0, prePaidAmount = 0;

        public decimal BDDiscount { get; set; }

        public decimal MCDiscount { get; set; }

        public int CustomerId { get; set; }

        public int? MemberTypeId { get; set; }

        public decimal? MCDiscountPercent { get; set; }

        public DialogResult _result;

        public decimal TotalAmt = 0;

        private decimal AmountWithExchange = 0;

        string CurrencySymbol = string.Empty;

        long total;

        string resultId = "-";

        int Qty = 0;

        List<Stock_Transaction> productList = new List<Stock_Transaction>();

        public List<string> TranIdList = new List<string>();

        Transaction CreditT = new Transaction();

        public Boolean IsPrint = true;
        public string Note = "";

        public int? tableId = null;
        public int servicefee = 0;
        int currencyID;
        long receiveAmount = 0;

        #endregion

        public frmPaidByCredit()
        {
            InitializeComponent();
        }

        private void frmPaidByCredit_Load(object sender, EventArgs e)
        {
            BindCurrency();
            BindPaymentMethodCombo();
            BindTransaction();           
        }

        #region Bind Currency 

        private void BindCurrency()
        {
            POSEntities entity = new POSEntities();
            Currency curreObj = new Currency();
            List<Currency> currencyList = new List<Currency>();
            currencyList = entity.Currencies.ToList();
            foreach (Currency c in currencyList)
            {
                cboCurrency.Items.Add(c.CurrencyCode);
            }
            currencyID = 0;
            if (SettingController.DefaultCurrency != 0)
            {
                currencyID = Convert.ToInt32(SettingController.DefaultCurrency);
                curreObj = entity.Currencies.FirstOrDefault(x => x.Id == currencyID);
                cboCurrency.Text = curreObj.CurrencyCode;
            }
            //txtExchangeRate.Text = SettingController.DefaultExchangeRate.ToString();

        }

        #endregion

        #region BindPayment
        private void BindPaymentMethodCombo()
        {
            cboPaymentMethod.DataSource = entity.PaymentTypes.Where(x => x.Id==1 || x.Id==5).ToList();
            cboPaymentMethod.DisplayMember = "Name";
            cboPaymentMethod.ValueMember = "Id";
        }
        #endregion

        #region Method
        private void BindTransaction()
        {
            foreach (Transaction tObj in CreditTransaction)
            {
                if (tObj.Transaction1.Count <= 0)
                {
                    totalAmount += (long)tObj.TotalAmount - (long)tObj.RecieveAmount;
                }
                //Has refund
                else
                {
                    totalAmount += (long)tObj.TotalAmount - (long)tObj.RecieveAmount;
                    foreach (Transaction Refund in tObj.Transaction1.Where(x => x.IsDeleted != true))
                    {
                        totalAmount -= (long)Refund.RecieveAmount;
                    }
                }
                if (tObj.UsePrePaidDebts != null)
                {
                    long prepaid = (long)tObj.UsePrePaidDebts.Sum(x => x.UseAmount);
                    totalAmount -= prepaid;
                }
            }
            foreach (Transaction tObj in PrePaidTransaction)
            {
                prePaidAmount += (long)tObj.TotalAmount;
                long useAmount = (tObj.UsePrePaidDebts1 == null) ? 0 : (int)tObj.UsePrePaidDebts1.Sum(x => x.UseAmount);
                prePaidAmount -= useAmount;
            }
            DebtAmount = (totalAmount);
            lblTotalCost.Text = Utility.CalculateExchangeRate(currencyID, DebtAmount).ToString();
            if (SettingController.TicketSale)
            {
                txtRecieveAmt.Text = lblTotalCost.Text;
            }
        }

        private bool CheckValidation()
        {
            if (cboCurrency.SelectedIndex == -1)
            {
                MessageBox.Show("Please Select Currency!","Paid By Credit",MessageBoxButtons.OK,MessageBoxIcon.Information);
                cboCurrency.Focus();
                return false;
            }
            if (receiveAmount == 0)
            {
                MessageBox.Show("Please fill up receive amount!", "Paid By Credit", MessageBoxButtons.OK, MessageBoxIcon.Information);
                txtRecieveAmt.Focus();
                return false;
            }
            else if (receiveAmount < AmountWithExchange)
            {
               
                MessageBox.Show("Receive amount must be greater than total cost!", "Paid By Credit", MessageBoxButtons.OK, MessageBoxIcon.Information);
                txtRecieveAmt.Focus();
                return false;                
            }

            return true;
        }

        private void Calculate()
        {
            POSEntities entity = new POSEntities();
            Boolean hasError = false;
            tp.RemoveAll();
            tp.IsBalloon = true;
            tp.ToolTipIcon = ToolTipIcon.Error;
            tp.ToolTipTitle = "Error";
            long receiveAmount = 0;
            long totalCost = (long)DetailList.Sum(x => x.TotalAmount) + (((long)DetailList.Sum(x => x.TotalAmount) * servicefee) / 100) - ExtraDiscount - (long)BDDiscount - (long)MCDiscount - GiftDiscountAmt;
            //total cost wint unit price
            long unitpriceTotalCost = (long)DetailList.Sum(x => x.UnitPrice * x.Qty);
            Int64.TryParse(txtRecieveAmt.Text, out receiveAmount);
            decimal totalCashSaleAmount = Convert.ToDecimal(lblTotalCost.Text);

            if (cboCurrency.SelectedIndex == -1)
            {
                tp.SetToolTip(cboCurrency, "Error");
                tp.Show("Please select currency!", cboCurrency);
                return;
            }
            string currVal = cboCurrency.Text;
            int currencyId = (from c in entity.Currencies where c.CurrencyCode == currVal select c.Id).SingleOrDefault();
            Currency cu = entity.Currencies.FirstOrDefault(x => x.Id == currencyId);

            //Validation
            if (receiveAmount == 0)
            {
                tp.SetToolTip(txtRecieveAmt, "Error");
                tp.Show("Please fill up receive amount!", txtRecieveAmt);
                hasError = true;
            }
            else if (receiveAmount < AmountWithExchange)
            {
                tp.SetToolTip(txtRecieveAmt, "Error");
                tp.Show("Receive amount must be greater than total cost!", txtRecieveAmt);
                hasError = true;
            }
            if (!hasError)
            {
                CurrencySymbol = string.Empty;
                Transaction insertedTransaction = new Transaction();
                List<Transaction> RefundList = new List<Transaction>();
                decimal change = 0;
                if (cu.CurrencyCode == "USD")
                {
                    totalCashSaleAmount = (decimal)totalCashSaleAmount * (decimal)cu.LatestExchangeRate;
                    receiveAmount = receiveAmount * (long)cu.LatestExchangeRate;
                    CurrencySymbol = "$";
                    change = Convert.ToDecimal(lblChanges.Text) * (decimal)cu.LatestExchangeRate;
                }
                else
                {
                    CurrencySymbol = "Ks";
                    change = Convert.ToDecimal(lblChanges.Text);
                }

                if (lblChangesText.Text == "Changes")
                {
                    receiveAmount -= Convert.ToInt64(lblChanges.Text);
                }
                if (cboPaymentMethod.SelectedIndex == 0)
                {
                    paymentType = Convert.ToInt32(cboPaymentMethod.SelectedValue);
                }
                else
                {
                    paymentType = Convert.ToInt32(cboBankPayment.SelectedValue);
                }

                long totalAmount = receiveAmount + prePaidAmount;
                long totalCredit = 0;
                Int64.TryParse(lblTotalCost.Text, out totalCredit);
                long DebtAmount = 0;
                if (totalAmount != 0)
                {
                    if (CreditTransaction.Count > 0)
                    {
                        int index = CreditTransaction.Count;
                        for (int outer = index - 1; outer >= 1; outer--)
                        {
                            for (int inner = 0; inner < outer; inner++)
                            {
                                if (CreditTransaction[inner].TotalAmount - CreditTransaction[inner].RecieveAmount < CreditTransaction[inner + 1].TotalAmount - CreditTransaction[inner + 1].RecieveAmount)
                                {
                                    Transaction t = CreditTransaction[inner];
                                    CreditTransaction[inner] = CreditTransaction[inner + 1];
                                    CreditTransaction[inner + 1] = t;
                                }
                            }
                        }
                        foreach (Transaction CT in CreditTransaction)
                        {
                            long CreditAmount = 0;
                            CreditAmount = (long)CT.TotalAmount - (long)CT.RecieveAmount;
                            RefundList = (from tr in entity.Transactions where tr.ParentId == CT.Id && tr.Type == TransactionType.CreditRefund select tr).ToList();
                            if (RefundList.Count > 0)
                            {
                                foreach (Transaction TRefund in RefundList)
                                {
                                    CreditAmount -= (long)TRefund.RecieveAmount;
                                }
                            }
                            if (CT.UsePrePaidDebts != null)
                            {
                                long prePaid = (long)CT.UsePrePaidDebts.Sum(x => x.UseAmount);
                                CreditAmount -= prePaid;
                            }
                            if (CreditAmount <= totalAmount)
                            {
                                CreditT = (from t in entity.Transactions where t.Id == CT.Id select t).FirstOrDefault<Transaction>();
                                CreditT.IsPaid = true;

                                TranIdList.Add(CreditT.Id);
                                entity.Entry(CreditT).State = EntityState.Modified;
                                entity.SaveChanges();
                                totalAmount -= CreditAmount;
                                if (CreditAmount <= receiveAmount)
                                {
                                    DebtAmount += CreditAmount;
                                    receiveAmount -= CreditAmount;
                                }
                                else
                                {
                                    CreditAmount -= receiveAmount;
                                    DebtAmount += receiveAmount;
                                    receiveAmount = 0;
                                    foreach (Transaction PrePaidDebtTrans in PrePaidTransaction)
                                    {
                                        long PrePaidamount = 0;
                                        //int useAmount = 0;
                                        int useAmount = (PrePaidDebtTrans.UsePrePaidDebts1 == null) ? 0 : (int)PrePaidDebtTrans.UsePrePaidDebts1.Sum(x => x.UseAmount);
                                        PrePaidamount = (long)PrePaidDebtTrans.TotalAmount - useAmount;
                                        if (CreditAmount >= PrePaidamount)
                                        {
                                            Transaction PD = (from PT in entity.Transactions where PT.Id == PrePaidDebtTrans.Id select PT).FirstOrDefault<Transaction>();
                                            PD.IsActive = true;
                                            entity.Entry(PD).State = EntityState.Modified;
                                            UsePrePaidDebt usePrePaidDObj = new UsePrePaidDebt();
                                            usePrePaidDObj.UseAmount = (int)PrePaidamount;
                                            usePrePaidDObj.PrePaidDebtTransactionId = PrePaidDebtTrans.Id;
                                            usePrePaidDObj.CreditTransactionId = CT.Id;
                                            usePrePaidDObj.CashierId = MemberShip.UserId;
                                            usePrePaidDObj.CounterId = MemberShip.CounterId;
                                            entity.UsePrePaidDebts.Add(usePrePaidDObj);
                                            entity.SaveChanges();
                                            CreditAmount -= PrePaidamount;
                                        }
                                        else
                                        {
                                            UsePrePaidDebt usePrePaidDObj = new UsePrePaidDebt();
                                            usePrePaidDObj.UseAmount = (int)CreditAmount;
                                            usePrePaidDObj.PrePaidDebtTransactionId = PrePaidDebtTrans.Id;
                                            usePrePaidDObj.CreditTransactionId = CT.Id;
                                            usePrePaidDObj.CashierId = MemberShip.UserId;
                                            usePrePaidDObj.CounterId = MemberShip.CounterId;
                                            entity.UsePrePaidDebts.Add(usePrePaidDObj);
                                            entity.SaveChanges();
                                            CreditAmount -= PrePaidamount;
                                        }
                                    }

                                    PrePaidTransaction = (from PDT in entity.Transactions where PDT.Type == TransactionType.Prepaid && PDT.IsActive == false select PDT).ToList();
                                }
                            }
                        }
                        if (DebtAmount > 0)
                        {

                            string joinedTranIdList = string.Join(",", TranIdList);
                            System.Data.Objects.ObjectResult<string> DebtId = entity.InsertTransaction(DateTime.Now, MemberShip.UserId, MemberShip.CounterId, TransactionType.Settlement, true, true, paymentType, 0, 0, DebtAmount, DebtAmount, null, CustomerId, MCDiscount, BDDiscount, MemberTypeId, MCDiscountPercent, true, joinedTranIdList, IsWholeSale, 0, SettingController.DefaultShop.Id, SettingController.DefaultShop.ShortCode, Note, tableId, servicefee);
                            string _Debt = DebtId.FirstOrDefault().ToString();

                            foreach (var t in TranIdList)
                            {
                                var result = (from tr in entity.Transactions where tr.Id == t select tr).FirstOrDefault();
                                result.TranVouNos = _Debt;
                                result.IsSettlement = true;
                                entity.Entry(result).State = EntityState.Modified;
                                entity.SaveChanges();
                            }
                            entity = new POSEntities();
                            resultId = _Debt;
                            insertedTransaction = (from trans in entity.Transactions where trans.Id == resultId select trans).FirstOrDefault<Transaction>();
                            insertedTransaction.ReceivedCurrencyId = cu.Id;
                            ExchangeRateForTransaction ex = new ExchangeRateForTransaction();
                            ex.TransactionId = resultId;
                            ex.CurrencyId = cu.Id;
                            ex.ExchangeRate = Convert.ToInt32(cu.LatestExchangeRate);
                            entity.ExchangeRateForTransactions.Add(ex);
                            entity.SaveChanges();
                            entity.SaveChanges();
                        }
                    }
                    else
                    {
                        totalAmount -= prePaidAmount;
                        receiveAmount -= prePaidAmount;
                    }
                }
                if (receiveAmount > 0)
                {
                    System.Data.Objects.ObjectResult<string> PreDebtId = entity.InsertTransaction(DateTime.Now, MemberShip.UserId, MemberShip.CounterId, TransactionType.Prepaid, true, false, paymentType, 0, 0, receiveAmount, receiveAmount, null, CustomerId, MCDiscount, BDDiscount, MemberTypeId, MCDiscountPercent, false, "", IsWholeSale, 0, SettingController.DefaultShop.Id, SettingController.DefaultShop.ShortCode, Note, tableId, servicefee);//,transactionParentId);
                    entity.SaveChanges();
                    if (DebtAmount == 0)
                    {
                        entity = new POSEntities();
                        resultId = PreDebtId.FirstOrDefault().ToString();
                        insertedTransaction = (from trans in entity.Transactions where trans.Id == resultId select trans).FirstOrDefault<Transaction>();
                        insertedTransaction.ReceivedCurrencyId = cu.Id;
                        ExchangeRateForTransaction ex = new ExchangeRateForTransaction();
                        ex.TransactionId = resultId;
                        ex.CurrencyId = cu.Id;
                        ex.ExchangeRate = Convert.ToInt32(cu.LatestExchangeRate);
                        entity.ExchangeRateForTransactions.Add(ex);
                        entity.SaveChanges();
                    }

                }
                if (isDraft)
                {
                    Transaction draft = (from trans in entity.Transactions where trans.Id == DraftId select trans).FirstOrDefault<Transaction>();
                    if (draft != null)
                    {
                        draft.TransactionDetails.Clear();
                        var Detail = entity.TransactionDetails.Where(d => d.TransactionId == draft.Id);
                        foreach (var d in Detail)
                        {
                            entity.TransactionDetails.Remove(d);
                        }
                        entity.Transactions.Remove(draft);
                        entity.SaveChanges();
                    }
                }


                //Print Invoice
                #region [ Print ]
                if (IsPrint)
                {
                    ReportViewer rv = new ReportViewer();
                    string reportPath = Application.StartupPath + Utility.GetReportPath("Settlement");
                    rv.Reset();
                    rv.LocalReport.ReportPath = reportPath;
                    Utility.Slip_Log(rv);
                    Utility.Slip_A4_Footer(rv);
                    APP_Data.Customer cus = entity.Customers.Where(x => x.Id == CustomerId).FirstOrDefault();

                    ReportParameter CustomerName = new ReportParameter("CustomerName", cus.Name);
                    rv.LocalReport.SetParameters(CustomerName);

                    if (insertedTransaction.Note.ToString() == "")
                    {
                        ReportParameter Notes = new ReportParameter("Notes", " ");
                        rv.LocalReport.SetParameters(Notes);
                    }
                    else
                    {
                        ReportParameter Notes = new ReportParameter("Notes", insertedTransaction.Note.ToString());
                        rv.LocalReport.SetParameters(Notes);
                    }

                    ReportParameter ShopName = new ReportParameter("ShopName", SettingController.ShopName);
                    rv.LocalReport.SetParameters(ShopName);

                    ReportParameter BranchName = new ReportParameter("BranchName", SettingController.BranchName);
                    rv.LocalReport.SetParameters(BranchName);

                    ReportParameter Phone = new ReportParameter("Phone", SettingController.PhoneNo);
                    rv.LocalReport.SetParameters(Phone);

                    ReportParameter OpeningHours = new ReportParameter("OpeningHours", SettingController.OpeningHours);
                    rv.LocalReport.SetParameters(OpeningHours);

                    ReportParameter TransactionId = new ReportParameter("TransactionId", resultId.ToString());
                    rv.LocalReport.SetParameters(TransactionId);

                    APP_Data.Counter c = entity.Counters.Where(x => x.Id == MemberShip.CounterId).FirstOrDefault();

                    ReportParameter CounterName = new ReportParameter("CounterName", c.Name);
                    rv.LocalReport.SetParameters(CounterName);

                    ReportParameter PrintDateTime = new ReportParameter();
                    switch (Utility.GetDefaultPrinter())
                    {
                        case "A4 Printer":
                            PrintDateTime = new ReportParameter("PrintDateTime", DateTime.Now.ToString("dd-MMM-yyyy"));
                            rv.LocalReport.SetParameters(PrintDateTime);
                            break;
                        case "Slip Printer":
                            PrintDateTime = new ReportParameter("PrintDateTime", DateTime.Now.ToString("dd/MM/yyyy hh:mm"));
                            rv.LocalReport.SetParameters(PrintDateTime);
                            break;
                    }

                    ReportParameter CasherName = new ReportParameter("CasherName", MemberShip.UserName);
                    rv.LocalReport.SetParameters(CasherName);


                    ReportParameter TotalAmount = new ReportParameter("TotalAmount", lblTotalCost.Text.ToString());
                    rv.LocalReport.SetParameters(TotalAmount);



                    ReportParameter PaidAmount = new ReportParameter("PaidAmount", txtRecieveAmt.Text);
                    rv.LocalReport.SetParameters(PaidAmount);

                    int balance = Convert.ToInt32(lblTotalCost.Text) - Convert.ToInt32(txtRecieveAmt.Text);
                    balance = balance < 0 ? 0 : balance;
                    ReportParameter Balance = new ReportParameter("Balance", balance.ToString());
                    rv.LocalReport.SetParameters(Balance);

                    int _change = Convert.ToInt32(txtRecieveAmt.Text) - Convert.ToInt32(lblTotalCost.Text);

                    _change = _change < 0 ? 0 : _change;
                    ReportParameter Change = new ReportParameter("Change", _change.ToString());
                    rv.LocalReport.SetParameters(Change);

                    if (Utility.GetDefaultPrinter() == "A4 Printer")
                    {
                        ReportParameter CusAddress = new ReportParameter("CusAddress", cus.Address);
                        rv.LocalReport.SetParameters(CusAddress);
                    }

                    Utility.Get_Print(rv);
                    #endregion
                }
                _result = MessageShow();
                if (System.Windows.Forms.Application.OpenForms["CustomerDetail"] != null)
                {
                    CustomerDetail newForm = (CustomerDetail)System.Windows.Forms.Application.OpenForms["CustomerDetail"];
                    newForm.Reload();
                }
                Note = "";
                this.Dispose();
            }
           
            if (_result.Equals(DialogResult.OK))
            {
                Common cm = new Common();
                cm.MemberTypeId = MemberTypeId;
                cm.TotalAmt = TotalAmt;
                cm.CustomerId = CustomerId;
                cm.type = 'S';
                cm.TransactionId = resultId;
                cm.Get_MType();
                if (System.Windows.Forms.Application.OpenForms["Sales"] != null)
                {
                    Sales newForm = (Sales)System.Windows.Forms.Application.OpenForms["Sales"];

                    newForm.Clear();
                }
            }

        }

        private DialogResult MessageShow()
        {
            DialogResult result = MessageBox.Show(this, "Payment Completed", "mPOS", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return result;
        }

        #endregion

        #region Selected Index Change
        private void cboCurrency_SelectedIndexChanged(object sender, EventArgs e)
        {
            int currencyId = 0;
            string currVal = cboCurrency.Text;
            currencyId = (from c in entity.Currencies where c.CurrencyCode == currVal select c.Id).SingleOrDefault();
            if (currencyId != 0)
            {
                Currency cu = entity.Currencies.FirstOrDefault(x => x.Id == currencyId);
                if (cu != null)
                {
                    if (!isDebt)
                    {

                        lblTotalCost.Text = Utility.CalculateExchangeRate(cu.Id, total).ToString();
                        AmountWithExchange = Convert.ToDecimal(lblTotalCost.Text);
                        decimal receive = 0;

                        Decimal.TryParse(txtRecieveAmt.Text, out receive);
                        decimal changes = AmountWithExchange - receive;

                        lblChanges.Text = changes.ToString();
                    }
                    else
                    {

                        lblTotalCost.Text = Utility.CalculateExchangeRate(cu.Id, DebtAmount).ToString();
                        AmountWithExchange = Convert.ToDecimal(lblTotalCost.Text);
                        decimal receive = 0;

                        Decimal.TryParse(txtRecieveAmt.Text, out receive);
                        decimal changes = AmountWithExchange - receive;
                        lblChanges.Text = changes.ToString();
                    }

                }
            }
        }

        private void cboPaymentMethod_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (cboPaymentMethod.SelectedIndex == 1)
            {
                lblBank.Visible = true;
                cboBankPayment.Visible = true;
                POSEntities posEntites = new POSEntities();
                var bankList = posEntites.PaymentTypes.Where(x => x.Id >= 501).ToList();
                cboBankPayment.DataSource = bankList;
                cboBankPayment.DisplayMember = "Name";
                cboBankPayment.ValueMember = "Id";
            }
            else
            {
                lblBank.Visible = false;
                cboBankPayment.Visible = false;
                cboBankPayment.DataSource = null;
            }
        }
        #endregion

        #region Key Press and KeyUp

        private void txtRecieveAmt_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar) && char.IsLetter('.'))
            {
                e.Handled = true;
            }
        }

        private void txtRecieveAmt_KeyUp(object sender, KeyEventArgs e)
        {
            decimal amount = 0;
            decimal.TryParse(txtRecieveAmt.Text, out amount);
            decimal Cost = 0;
            decimal.TryParse(lblTotalCost.Text, out Cost);

            if (txtRecieveAmt.Text != string.Empty)
            {
                if (!isDebt)
                {
                    lblChanges.Text = (amount - Cost).ToString();
                }
                else
                {
                    decimal DAmount = Convert.ToDecimal(lblTotalCost.Text);
                    string currVal = cboCurrency.Text;
                    int cId = (from c in entity.Currencies where c.CurrencyCode == currVal select c.Id).SingleOrDefault();
                    Currency currencyObj = entity.Currencies.FirstOrDefault(x => x.Id == cId);
                    if (amount >= DAmount)
                    {
                        lblChanges.Text = (amount - DAmount).ToString();
                        lblChangesText.Text = "Changes";
                    }
                    else
                    {
                        lblChangesText.Text = "Net Payable";
                        lblChanges.Text = (DAmount - amount).ToString();
                    }
                }
            }
        }

        #endregion

        #region Button Click

        private void btnSubmit_Click(object sender, EventArgs e)
        {
            Calculate();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Dispose();
        }

        #endregion
        
    }
}
