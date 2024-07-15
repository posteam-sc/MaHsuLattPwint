using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Reporting.WinForms;
using POS.APP_Data;

namespace POS
{
    public partial class TransactionDetailForm : Form
    {
        #region Variable

        private POSEntities entity = new POSEntities();
        public string transactionId;
        public string transactionDetailId;
        int ExtraDiscount, ExtraTax;
        long unitpriceTotalCost;
        private int CustomerId = 0;
        public int shopid;
       public bool delete = false;
       public bool DeleteLink = true;
       int Qty = 0;
       public DateTime date;
       public Boolean IsCash = true;

       List<Stock_Transaction> productList = new List<Stock_Transaction>();

        #endregion

        #region Event

        public TransactionDetailForm()
        {
            InitializeComponent();
        }

        private void TransactionDetailForm_Load(object sender, EventArgs e)
        {
            Localization.Localize_FormControls(this);
            //Localization.Localize_FormControls(this);
            List<APP_Data.Customer> customerList = new List<APP_Data.Customer>();
            APP_Data.Customer customer = new APP_Data.Customer();
            customer.Id = 0;
            customer.Name = "None";
            customerList.Add(customer);
            customerList.AddRange(entity.Customers.ToList());
            cboCustomer.DataSource = customerList;
            cboCustomer.DisplayMember = "Name";
            cboCustomer.ValueMember = "Id";
            cboCustomer.AutoCompleteMode = AutoCompleteMode.SuggestAppend;
            cboCustomer.AutoCompleteSource = AutoCompleteSource.ListItems;
            LoadData();            
        }        

        private void dgvTransactionDetail_DataBindingComplete(object sender, DataGridViewBindingCompleteEventArgs e)
        {
            foreach (DataGridViewRow row in dgvTransactionDetail.Rows)
            {
                TransactionDetail transactionDetailObj = (TransactionDetail)row.DataBoundItem;
                row.Cells[0].Value = transactionDetailObj.Product.ProductCode;
                row.Cells[1].Value = transactionDetailObj.Product.Name;
                row.Cells[2].Value = transactionDetailObj.Qty;


                string tranId = transactionDetailObj.TransactionId;
                var _result = entity.Transactions.Where(x => x.ParentId == tranId && x.IsDeleted == false).ToList();

                var _refundIdList = _result.Select(x => x.Id).ToList();

                if (_result.Count > 0)
                {
                    string proCode = transactionDetailObj.Product.ProductCode;

                    var proId = entity.Products.Where(x => x.ProductCode == proCode).Select(x => x.Id).FirstOrDefault();

                    List<TransactionDetail> td =new List<TransactionDetail>();
                    if (IsCash)
                    {
                        td = entity.TransactionDetails.Where(x => _refundIdList.Contains(x.TransactionId) && x.ProductId == proId).ToList();
                        row.Cells[3].Value = td.Count;
                    }
                    else
                    {
                       // td = entity.TransactionDetails.Where(x => _refundIdList.Contains(x.TransactionId) && x.ProductId == proId).ToList();
                      var  data=(from dd in entity.TransactionDetails 
                                join t in entity.Transactions on dd.TransactionId equals t.Id 
                                where _refundIdList.Contains(dd.TransactionId) && dd.ProductId==proId && (t.Type==TransactionType.CreditRefund || t.Type==TransactionType.Refund) select td).ToList();
                      row.Cells[3].Value = data.Count;
                    }
                    
                }
                else
                {
                    row.Cells[3].Value = 0;
                }

                row.Cells[4].Value = transactionDetailObj.UnitPrice;
                //row.Cells[4].Value = transactionDetailObj.SellingPrice;
                row.Cells[5].Value = transactionDetailObj.DiscountRate + "%";
                row.Cells[6].Value = transactionDetailObj.TaxRate + "%";
                row.Cells[7].Value = transactionDetailObj.TotalAmount;

                int discountamt = Convert.ToInt32(row.Cells[3].Value) * Convert.ToInt32(transactionDetailObj.UnitPrice) * Convert.ToInt32(transactionDetailObj.DiscountRate) / 100;

                row.Cells[8].Value = (Convert.ToInt32(row.Cells[3].Value) * transactionDetailObj.UnitPrice)  - discountamt; 
               // row.Cells[7].Value = transactionDetailObj.ProductId;
                //row.Cells[10].Value = transactionDetailObj.IsFOC;
                if (transactionDetailObj.IsFOC == true)
                {
                    row.Cells[10].Value = "FOC";
                }
                else
                {
                    row.Cells[10].Value = "";
                }

                if (Convert.ToInt32(row.Cells[2].Value) == Convert.ToInt32(row.Cells[3].Value))
                {
                    row.DefaultCellStyle.BackColor = Color.LightSkyBlue;
                  
                }

                
            }
        }

        private void btnPrint_Click(object sender, EventArgs e)
        {
            string _defaultPrinter = Utility.GetDefaultPrinter();
            CustomerId = Convert.ToInt32(cboCustomer.SelectedValue);
            int _tAmt = 0;
            Transaction transactionObj = (from t in entity.Transactions where t.Id == transactionId select t).FirstOrDefault();

            string tranId = transactionObj.Id;

            List<TransactionDetail> _tdList = (from td in transactionObj.TransactionDetails where td.IsDeleted == false select td).ToList();

            #region for refund
            var _result = entity.Transactions.Where(x => x.ParentId == tranId && x.IsDeleted == false).ToList();

            var _refundIdList = _result.Select(x => x.Id).ToList();

            var _refundDiscountamt = _result.Select(x => x.DiscountAmount).Sum();

            var refundDetailList= entity.TransactionDetails.Where(x => _refundIdList.Contains(x.TransactionId)).ToList();
         

             int _refundItemDiscAmt=0;
            foreach (var detail in refundDetailList)
            {
                _refundItemDiscAmt += Convert.ToInt32(detail.UnitPrice * detail.Qty) / 100 * Convert.ToInt32(detail.DiscountRate);
            }

          // int discountAmt = Convert.ToInt32(transactionObj.DiscountAmount - _refundDiscountamt);
            int totalItemDisAmt = 0; int toalDiscAmt = 0;
            #endregion

            unitpriceTotalCost = 0; Int64 _mcDiscountAmt = 0; Int64 _bcDiscountAmt = 0; Int64 totalAmountRep = 0;

            if (transactionObj.PaymentTypeId == 2)
            {
                #region [ Print ] for Credit

                int outStandingAmount = 0;
                Int32.TryParse(lblOutstandingAmount.Text, out outStandingAmount);
                dsReportTemp dsReport = new dsReportTemp();
                dsReportTemp.ItemListDataTable dtReport = (dsReportTemp.ItemListDataTable)dsReport.Tables["ItemList"];

                int settlementAmt = 0;
                if (transactionObj.TranVouNos != string.Empty && transactionObj.TranVouNos != null)
                {
                    settlementAmt = Convert.ToInt32(entity.Transactions.Where(x => x.Id == transactionObj.TranVouNos).Select(x => x.TotalAmount).Sum());
                }

                foreach (TransactionDetail transaction in _tdList)
                {
                    dsReportTemp.ItemListRow newRow = dtReport.NewItemListRow();
                    newRow.Name = transaction.Product.Name;
                    newRow.Qty = transaction.Qty.ToString();
                    newRow.PhotoPath = string.IsNullOrEmpty(transaction.Product.PhotoPath) ? "" : Application.StartupPath + transaction.Product.PhotoPath.Remove(0, 1);
                    //ZP(TDO)
                    newRow.DiscountPercent = transaction.DiscountRate.ToString();
                    // newRow.DiscountPercent = Convert.ToInt32(transaction.DiscountRate).ToString();
                    newRow.TotalAmount = (int)transaction.UnitPrice * (int)transaction.Qty; //Edit By ZMH

                    if (transaction.IsFOC == true)
                    {
                        newRow.IsFOC = "FOC";
                    }

                    //    newRow.TotalAmount = (int)transaction.TotalAmount;
                    switch (Utility.GetDefaultPrinter())
                    {
                        case "A4 Printer":
                            newRow.UnitPrice = transaction.UnitPrice.ToString();
                            break;
                        case "Slip Printer":
                            newRow.UnitPrice = "1@" + transaction.UnitPrice.ToString();
                            break;
                    }



                    if (_result.Count > 0)
                    {

                        List<TransactionDetail> td = entity.TransactionDetails.Where(x => _refundIdList.Contains(x.TransactionId) && x.ProductId == transaction.ProductId).ToList();

                        if (td.Count != transaction.Qty)
                        {
                            int currentQty = Convert.ToInt32(transaction.Qty - td.Count);
                            newRow.Qty = currentQty.ToString();
                            newRow.TotalAmount = (int)transaction.UnitPrice * currentQty;
                            dtReport.AddItemListRow(newRow);
                            _tAmt += newRow.TotalAmount;

                        }

                    }
                    else
                    {
                        _tAmt += newRow.TotalAmount;

                        dtReport.AddItemListRow(newRow);
                    }

                }

                if (dtReport.Count > 0)
                {
                    int CusId = Convert.ToInt32(cboCustomer.SelectedValue);
                    // int PrepaidDebt = 0;
                    List<Transaction> rtList = new List<Transaction>();
                    List<Transaction> OldOutStandingList = entity.Transactions.Where(x => x.CustomerId == CusId && !x.Id.Contains(tranId)).ToList().Where(x => x.IsDeleted != true).ToList();
                    long OldOutstandingAmount = 0;
                    foreach (Transaction ts in OldOutStandingList)
                    {
                        if (ts.IsPaid == false)
                        {
                            OldOutstandingAmount += (long)ts.TotalAmount - (long)ts.RecieveAmount;
                            rtList = (from t in entity.Transactions where t.Type == TransactionType.CreditRefund && t.ParentId == ts.Id select t).ToList();
                            if (rtList.Count > 0)
                            {
                                foreach (Transaction rt in rtList)
                                {
                                    OldOutstandingAmount -= (int)rt.RecieveAmount;
                                }
                            }
                        }

                    }

                    string reportPath = "";
                    ReportViewer rv = new ReportViewer();
                    ReportDataSource rds = new ReportDataSource("DataSet1", dsReport.Tables["ItemList"]);
                    reportPath = Application.StartupPath + Utility.GetReportPath("Credit");
                    rv.Reset();
                    rv.LocalReport.ReportPath = reportPath;
                    rv.LocalReport.DataSources.Add(rds);

                    Utility.Slip_Log(rv);
                    //switch (_defaultPrinter)
                    //{

                    //    case "Slip Printer":
                    //        Utility.Slip_A4_Footer(rv);
                    //        break;
                    //}
                    Utility.Slip_A4_Footer(rv);

                    if (Convert.ToInt32(transactionObj.MCDiscountAmt) != 0)
                    {
                        _mcDiscountAmt = Convert.ToInt64(transactionObj.MCDiscountAmt);
                        ReportParameter MCDiscountAmt = new ReportParameter("MCDiscount", "-" + _mcDiscountAmt.ToString());
                        rv.LocalReport.SetParameters(MCDiscountAmt);
                    }

                    else if (Convert.ToInt32(transactionObj.BDDiscountAmt) != 0)
                    {
                        _bcDiscountAmt = Convert.ToInt64(transactionObj.BDDiscountAmt);
                        ReportParameter BCDiscountAmt = new ReportParameter("MCDiscount", "-" + _bcDiscountAmt.ToString());
                        rv.LocalReport.SetParameters(BCDiscountAmt);
                    }
                    else
                    {
                        ReportParameter BCDiscountAmt = new ReportParameter("MCDiscount", "0");
                        rv.LocalReport.SetParameters(BCDiscountAmt);
                    }
                    string _tAmt1 = string.Format("{0:#,##0.00}", _tAmt);
                    ReportParameter TAmt = new ReportParameter("TAmt", _tAmt1);
                    rv.LocalReport.SetParameters(TAmt);
                    if (SettingController.SelectDefaultPrinter != "Slip Printer")
                    {
                        ReportParameter PrintProductImage = new ReportParameter("PrintImage", SettingController.ShowProductImageIn_A4Reports.ToString());
                        rv.LocalReport.SetParameters(PrintProductImage);
                    }
                    if (transactionObj.Note == null)
                    {
                        ReportParameter Notes = new ReportParameter("Notes", " ");
                        rv.LocalReport.SetParameters(Notes);
                    }
                    else
                    {
                        ReportParameter Notes = new ReportParameter("Notes", transactionObj.Note.ToString());
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

                    ReportParameter TransactionId = new ReportParameter("TransactionId", transactionId.ToString());
                    rv.LocalReport.SetParameters(TransactionId);

                    APP_Data.Counter counter = entity.Counters.FirstOrDefault(x => x.Id == MemberShip.CounterId);

                    ReportParameter CounterName = new ReportParameter("CounterName", counter.Name);
                    rv.LocalReport.SetParameters(CounterName);

                    ReportParameter TotalGiftDiscount = new ReportParameter("TotalGiftDiscount", transactionObj.MCDiscountAmt.ToString());
                    rv.LocalReport.SetParameters(TotalGiftDiscount);

                    ReportParameter PrintDateTime = new ReportParameter();
                    switch (Utility.GetDefaultPrinter())
                    {
                        case "A4 Printer":
                            PrintDateTime = new ReportParameter("PrintDateTime", Convert.ToDateTime(transactionObj.DateTime).ToString("dd-MMM-yyyy"));
                            rv.LocalReport.SetParameters(PrintDateTime);
                            break;
                        case "Slip Printer":
                            PrintDateTime = new ReportParameter("PrintDateTime", Convert.ToDateTime(transactionObj.DateTime).ToString("dd/MM/yyyy hh:mm"));
                            rv.LocalReport.SetParameters(PrintDateTime);
                            break;
                    }

                    ReportParameter CasherName = new ReportParameter("CasherName", MemberShip.UserName);
                    rv.LocalReport.SetParameters(CasherName);


                    toalDiscAmt = Convert.ToInt32(transactionObj.DiscountAmount) - Convert.ToInt32(_refundDiscountamt) - _refundItemDiscAmt;
                    //   Int64 totalAmountRep = transactionObj.TotalAmount == null ? 0 : Convert.ToInt64(transactionObj.TotalAmount); //Edit By ZMH
                    int taxamt = Convert.ToInt32(transactionObj.TaxAmount);
                    totalAmountRep = (_tAmt - _bcDiscountAmt - _mcDiscountAmt - toalDiscAmt) + taxamt;
                    ReportParameter TotalAmount = new ReportParameter("TotalAmount", totalAmountRep.ToString());
                    rv.LocalReport.SetParameters(TotalAmount);

                    ReportParameter TaxAmount = new ReportParameter("TaxAmount", transactionObj.TaxAmount.ToString());
                    rv.LocalReport.SetParameters(TaxAmount);

                    if (toalDiscAmt == 0)
                    {
                        ReportParameter DiscountAmount = new ReportParameter("DiscountAmount", toalDiscAmt.ToString());
                        rv.LocalReport.SetParameters(DiscountAmount);
                    }
                    else
                    {
                        ReportParameter DiscountAmount = new ReportParameter("DiscountAmount", "-" + toalDiscAmt.ToString());
                        rv.LocalReport.SetParameters(DiscountAmount);
                    }

                    int paidAmt = 0;
                    if (transactionObj.IsSettlement == false)
                    {
                        paidAmt = Convert.ToInt32(transactionObj.RecieveAmount);
                        ReportParameter PaidAmount = new ReportParameter("PaidAmount", paidAmt.ToString());
                        rv.LocalReport.SetParameters(PaidAmount);
                    }
                    else
                    {
                        paidAmt = settlementAmt + Convert.ToInt32(transactionObj.RecieveAmount);
                        ReportParameter PaidAmount = new ReportParameter("PaidAmount", paidAmt.ToString());
                        rv.LocalReport.SetParameters(PaidAmount);
                    }

                    ReportParameter PrevOutstanding = new ReportParameter("PrevOutstanding", OldOutstandingAmount.ToString());
                    rv.LocalReport.SetParameters(PrevOutstanding);

                    ReportParameter PrePaidDebt = new ReportParameter("PrePaidDebt", lblOutstandingAmount.Text);
                    rv.LocalReport.SetParameters(PrePaidDebt);

                    //  ReportParameter NetPayable = new ReportParameter("NetPayable", (OldOutstandingAmount + transactionObj.TotalAmount - Convert.ToInt32(lblOutstandingAmount.Text)).ToString());
                    //ReportParameter NetPayable = new ReportParameter("NetPayable", (OldOutstandingAmount + totalAmountRep - Convert.ToInt32(lblOutstandingAmount.Text) - settlementAmt).ToString());
                    int netpayable = (Convert.ToInt32(totalAmountRep) + Convert.ToInt32(OldOutstandingAmount)) - Convert.ToInt32(lblOutstandingAmount.Text);
                    ReportParameter NetPayable = new ReportParameter("NetPayable", netpayable.ToString());
                    rv.LocalReport.SetParameters(NetPayable);

                    //ReportParameter Balance = new ReportParameter("Balance", (OldOutstandingAmount + transactionObj.TotalAmount - (Convert.ToInt32(lblOutstandingAmount.Text)) - transactionObj.RecieveAmount).ToString());
                    //ReportParameter Balance = new ReportParameter("Balance", (OldOutstandingAmount + totalAmountRep - (Convert.ToInt32(lblOutstandingAmount.Text)) - transactionObj.RecieveAmount - settlementAmt).ToString());
                    ReportParameter Balance = new ReportParameter("Balance", (netpayable - paidAmt).ToString());
                    rv.LocalReport.SetParameters(Balance);


                    ReportParameter CustomerName = new ReportParameter("CustomerName", transactionObj.Customer.Name);
                    rv.LocalReport.SetParameters(CustomerName);
                   

                if (SettingController.UseTable || SettingController.UseQueue)
                {
                        bool IsRestaurant = SettingController.UseTable ? SettingController.UseTable : SettingController.UseQueue ? SettingController.UseQueue : false;
                        ReportParameter restaurant = new ReportParameter("IsRestaurant", IsRestaurant.ToString());
                        rv.LocalReport.SetParameters(restaurant);
                        ReportParameter tblORque = new ReportParameter("TBLorQue", SettingController.UseTable && transactionObj.TableIdOrQue != null ? "# : " + entity.RestaurantTables.Find(transactionObj.TableIdOrQue).Number 
                                                                        : SettingController.UseQueue && transactionObj.TableIdOrQue != null ? "# : " + transactionObj.TableIdOrQue.ToString().PadLeft(4,'0') : null);
                        rv.LocalReport.SetParameters(tblORque);
                        ReportParameter servicepercent = new ReportParameter("ServicePercent", transactionObj.ServiceFee.ToString());
                        rv.LocalReport.SetParameters(servicepercent);
                        ReportParameter servicecharge = new ReportParameter("ServiceFee", ((transactionObj.TransactionDetails.Sum(a => a.TotalAmount)) * transactionObj.ServiceFee / 100).ToString());
                    rv.LocalReport.SetParameters(servicecharge);
                }

                    if (Utility.GetDefaultPrinter() == "A4 Printer")
                    {
                        ReportParameter CusAddress = new ReportParameter("CusAddress", transactionObj.Customer.Address);
                        rv.LocalReport.SetParameters(CusAddress);
                    }
                    var c =rv.LocalReport.GetParameters();
                    foreach (var item in c)
                    {
                        
                    }
                    //// PrintDoc.PrintReport(rv, Utility.GetDefaultPrinter());
                    Utility.Get_Print(rv);
                }
                else
                {
                    MessageBox.Show("Invoice No." + tranId + "  is already made refund all items.", "mPOS");
                }
                #endregion

            }
            else if (transactionObj.PaymentTypeId == 3)
            {
                #region [ Print ] for GiftCard

                dsReportTemp dsReport = new dsReportTemp();
                dsReportTemp.ItemListDataTable dtReport = (dsReportTemp.ItemListDataTable)dsReport.Tables["ItemList"];
                //List<TransactionDetail> _tdList = (from td in transactionObj.TransactionDetails where td.IsDeleted == false select td).ToList();



                foreach (TransactionDetail transaction in _tdList)
                {
                    dsReportTemp.ItemListRow newRow = dtReport.NewItemListRow();
                    newRow.Name = transaction.Product.Name;
                    newRow.Qty = transaction.Qty.ToString();
                    //newRow.TotalAmount = (int)transaction.TotalAmount;

                    newRow.DiscountPercent = transaction.DiscountRate.ToString();
                    newRow.TotalAmount = (int)transaction.UnitPrice * (int)transaction.Qty; //Edit By ZMH
                    newRow.PhotoPath = string.IsNullOrEmpty(transaction.Product.PhotoPath) ? "" : Application.StartupPath + transaction.Product.PhotoPath.Remove(0, 1);

                    // dtReport.AddItemListRow(newRow);
                    unitpriceTotalCost = (int)transaction.UnitPrice * (int)transaction.Qty;

                    if (transaction.IsFOC == true)
                    {
                        newRow.IsFOC = "FOC";
                    }
                    switch (Utility.GetDefaultPrinter())
                    {
                        case "A4 Printer":
                            newRow.UnitPrice = transaction.UnitPrice.ToString();
                            break;
                        case "Slip Printer":
                            newRow.UnitPrice = "1@" + transaction.UnitPrice.ToString();
                            break;
                    }
                    _tAmt += newRow.TotalAmount;
                    dtReport.AddItemListRow(newRow);


                }


                if (dtReport.Count > 0)
                {
                    string reportPath = "";
                    ReportViewer rv = new ReportViewer();
                    ReportDataSource rds = new ReportDataSource("DataSet1", dsReport.Tables["ItemList"]);
                    reportPath = Application.StartupPath + Utility.GetReportPath("GiftCard");

                    rv.Reset();
                    rv.LocalReport.ReportPath = reportPath;
                    rv.LocalReport.DataSources.Add(rds);

                    Utility.Slip_Log(rv);
                    //switch (_defaultPrinter)
                    //{

                    //   case "Slip Printer":
                    //Utility.Slip_A4_Footer(rv);
                    //     break;
                    // }

                    Utility.Slip_A4_Footer(rv);

                    APP_Data.Customer cus = entity.Customers.Where(x => x.Id == CustomerId).FirstOrDefault();

                    ReportParameter CustomerName = new ReportParameter("CustomerName", cus.Name);
                    rv.LocalReport.SetParameters(CustomerName);

                    if (Convert.ToInt32(transactionObj.MCDiscountAmt) != 0)
                    {
                        _mcDiscountAmt = Convert.ToInt64(transactionObj.MCDiscountAmt);
                        ReportParameter MCDiscountAmt = new ReportParameter("MCDiscount", "-" + _mcDiscountAmt.ToString());
                        rv.LocalReport.SetParameters(MCDiscountAmt);
                    }

                    else if (Convert.ToInt32(transactionObj.BDDiscountAmt) != 0)
                    {
                        _bcDiscountAmt = Convert.ToInt64(transactionObj.BDDiscountAmt);
                        ReportParameter BCDiscountAmt = new ReportParameter("MCDiscount", "-" + _bcDiscountAmt.ToString());
                        rv.LocalReport.SetParameters(BCDiscountAmt);
                    }
                    else
                    {
                        ReportParameter BCDiscountAmt = new ReportParameter("MCDiscount", "0");
                        rv.LocalReport.SetParameters(BCDiscountAmt);
                    }

                    ReportParameter TAmt = new ReportParameter("TAmt", _tAmt.ToString());
                    rv.LocalReport.SetParameters(TAmt);
                    if (SettingController.SelectDefaultPrinter != "Slip Printer")
                    {
                        ReportParameter PrintProductImage = new ReportParameter("PrintImage", SettingController.ShowProductImageIn_A4Reports.ToString());
                        rv.LocalReport.SetParameters(PrintProductImage);
                    }
                    if (transactionObj.Note.ToString() == "")
                    {
                        ReportParameter Notes = new ReportParameter("Notes", " ");
                        rv.LocalReport.SetParameters(Notes);
                    }
                    else
                    {
                        ReportParameter Notes = new ReportParameter("Notes", transactionObj.Note.ToString());
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

                    ReportParameter TransactionId = new ReportParameter("TransactionId", transactionId.ToString());
                    rv.LocalReport.SetParameters(TransactionId);

                    APP_Data.Counter c = entity.Counters.FirstOrDefault(x => x.Id == MemberShip.CounterId);

                    ReportParameter CounterName = new ReportParameter("CounterName", c.Name);
                    rv.LocalReport.SetParameters(CounterName);

                    ReportParameter TotalGiftDiscount = new ReportParameter("TotalGiftDiscount", transactionObj.MCDiscountAmt.ToString());
                    rv.LocalReport.SetParameters(TotalGiftDiscount);

                    ReportParameter PrintDateTime = new ReportParameter();
                    switch (Utility.GetDefaultPrinter())
                    {
                        case "A4 Printer":
                            PrintDateTime = new ReportParameter("PrintDateTime", Convert.ToDateTime(transactionObj.DateTime).ToString("dd-MMM-yyyy"));
                            rv.LocalReport.SetParameters(PrintDateTime);
                            break;
                        case "Slip Printer":
                            PrintDateTime = new ReportParameter("PrintDateTime", Convert.ToDateTime(transactionObj.DateTime).ToString("dd/MM/yyyy hh:mm"));
                            rv.LocalReport.SetParameters(PrintDateTime);
                            break;
                    }

                    ReportParameter CasherName = new ReportParameter("CasherName", MemberShip.UserName);
                    rv.LocalReport.SetParameters(CasherName);

                    //Int64 totalAmountRep = transactionObj.TotalAmount == null ? 0 : Convert.ToInt64(transactionObj.TotalAmount); //Edit By ZMH


                    //totalAmountRep = (_tAmt + _bcDiscountAmt + _mcDiscountAmt - Convert.ToInt32(transactionObj.DiscountAmount));
                    //ReportParameter TotalAmount = new ReportParameter("TotalAmount", totalAmountRep.ToString());
                    //rv.LocalReport.SetParameters(TotalAmount);

                    totalAmountRep = Convert.ToInt32(transactionObj.TotalAmount) - Convert.ToInt32(transactionObj.GiftCardAmount);
                    ReportParameter TotalAmount = new ReportParameter("TotalAmount", (totalAmountRep + (totalAmountRep * transactionObj.ServiceFee / 100)).ToString());
                    rv.LocalReport.SetParameters(TotalAmount);

                    Int64 GiftCardAmt = Convert.ToInt32(transactionObj.GiftCardAmount);
                    ReportParameter usedGiftCardAmt = new ReportParameter("UsedGiftCardAmt", GiftCardAmt.ToString());
                    rv.LocalReport.SetParameters(usedGiftCardAmt);

                    ReportParameter TaxAmount = new ReportParameter("TaxAmount", transactionObj.TaxAmount.ToString());
                    rv.LocalReport.SetParameters(TaxAmount);

                    if (Convert.ToInt32(transactionObj.DiscountAmount) == 0)
                    {
                        ReportParameter DiscountAmount = new ReportParameter("DiscountAmount", transactionObj.DiscountAmount.ToString());
                        rv.LocalReport.SetParameters(DiscountAmount);
                    }
                    else
                    {
                        ReportParameter DiscountAmount = new ReportParameter("DiscountAmount", "-" + transactionObj.DiscountAmount.ToString());
                        rv.LocalReport.SetParameters(DiscountAmount);
                    }

                    ReportParameter PaidAmount = new ReportParameter("PaidAmount", transactionObj.RecieveAmount.ToString());
                    rv.LocalReport.SetParameters(PaidAmount);

                    ReportParameter Change = new ReportParameter("Change", (transactionObj.RecieveAmount - (totalAmountRep+(totalAmountRep*SettingController.ServiceFee/100))).ToString());
                    rv.LocalReport.SetParameters(Change);

                  

                    if (SettingController.UseTable || SettingController.UseQueue)
                    {
                        bool IsRestaurant = SettingController.UseTable ? SettingController.UseTable : SettingController.UseQueue ? SettingController.UseQueue : false;
                        ReportParameter restaurant = new ReportParameter("IsRestaurant", IsRestaurant.ToString());
                        rv.LocalReport.SetParameters(restaurant);
                        ReportParameter tblORque = new ReportParameter("TBLorQue", SettingController.UseTable && transactionObj.TableIdOrQue != null ? "# : " + entity.RestaurantTables.Find(transactionObj.TableIdOrQue).Number
                                                                       : SettingController.UseQueue && transactionObj.TableIdOrQue != null ? "# : " + transactionObj.TableIdOrQue.ToString().PadLeft(4, '0') : null);
                        rv.LocalReport.SetParameters(tblORque);
                        ReportParameter servicepercent = new ReportParameter("ServicePercent", transactionObj.ServiceFee.ToString());
                        rv.LocalReport.SetParameters(servicepercent);
                        ReportParameter servicecharge = new ReportParameter("ServiceFee", ((transactionObj.TransactionDetails.Sum(a => a.TotalAmount)) * transactionObj.ServiceFee / 100).ToString());
                        rv.LocalReport.SetParameters(servicecharge);
                    }

                    ReportParameter GiftCardNo = new ReportParameter("GiftCardNo", transactionObj.GiftCard.CardNumber.ToString());
                    rv.LocalReport.SetParameters(GiftCardNo);

                    if (Utility.GetDefaultPrinter() == "A4 Printer")
                    {
                        ReportParameter CusAddress = new ReportParameter("CusAddress", transactionObj.Customer.Address);
                        rv.LocalReport.SetParameters(CusAddress);
                    }

                    ////  PrintDoc.PrintReport(rv,Utility.GetDefaultPrinter());
                    Utility.Get_Print(rv);
                }
                else
                {
                    MessageBox.Show("Invoice No." + tranId + "  is already made refund all items.", "mPOS");
                }
                #endregion
            }
            else if (transactionObj.PaymentTypeId == 1)
            {
                #region [ Print ] for Cash


                dsReportTemp dsReport = new dsReportTemp();
                dsReportTemp.ItemListDataTable dtReport = (dsReportTemp.ItemListDataTable)dsReport.Tables["ItemList"];
                //List<TransactionDetail> _tdList = (from td in transactionObj.TransactionDetails where td.IsDeleted == false select td).ToList();



                foreach (TransactionDetail transaction in _tdList)
                {
                    dsReportTemp.ItemListRow newRow = dtReport.NewItemListRow();
                    newRow.ItemId = transaction.Product.ProductCode;
                    newRow.Name = transaction.Product.Name;
                    newRow.Qty = transaction.Qty.ToString();
                    newRow.PhotoPath = string.IsNullOrEmpty(transaction.Product.PhotoPath) ? "" : Application.StartupPath + transaction.Product.PhotoPath.Remove(0, 1);

                  
                    //newRow.TotalAmount = (int)transaction.TotalAmount; //Edit By ZMH
                    //ZP(TDO)
                    newRow.DiscountPercent = transaction.DiscountRate.ToString();
                    //  newRow.DiscountPercent = Convert.ToInt32(transaction.DiscountRate).ToString();
                    newRow.TotalAmount = (int)transaction.UnitPrice * (int)transaction.Qty; //Edit By ZMH


                    if (transaction.IsFOC == true)
                    {
                        newRow.IsFOC = "FOC";
                    }

                    switch (Utility.GetDefaultPrinter())
                    {
                        case "A4 Printer":
                            newRow.UnitPrice = transaction.UnitPrice.ToString();
                            break;
                        case "Slip Printer":
                            newRow.UnitPrice = "1@" + transaction.UnitPrice.ToString();
                            break;
                    }
                    //   _tAmt += newRow.TotalAmount;


                    if (_result.Count > 0)
                    {

                        List<TransactionDetail> td = entity.TransactionDetails.Where(x => _refundIdList.Contains(x.TransactionId) && x.ProductId == transaction.ProductId).ToList();

                        if (td.Count != transaction.Qty)
                        {
                            int currentQty = Convert.ToInt32(transaction.Qty - td.Count);
                            newRow.Qty = currentQty.ToString();
                            newRow.TotalAmount = (int)transaction.UnitPrice * currentQty;
                            dtReport.AddItemListRow(newRow);
                            _tAmt += newRow.TotalAmount;
                            totalItemDisAmt += Convert.ToInt32(transaction.TotalAmount) - Convert.ToInt32(transactionObj.DiscountAmount);
                        }

                    }
                    else
                    {
                        _tAmt += newRow.TotalAmount;

                        totalItemDisAmt += Convert.ToInt32(transactionObj.DiscountAmount);
                        dtReport.AddItemListRow(newRow);
                    }


                    // dtReport.AddItemListRow(newRow);
                    // unitpriceTotalCost = (int)transaction.UnitPrice * (int)transaction.Qty;                    
                }


                if (dtReport.Count > 0)
                {

                    string reportPath = "";
                    ReportViewer rv = new ReportViewer();
                    ReportDataSource rds = new ReportDataSource("DataSet1", dsReport.Tables["ItemList"]);

                    reportPath = Application.StartupPath + Utility.GetReportPath("Cash");
                    rv.Reset();
                    rv.LocalReport.ReportPath = reportPath;
                    rv.LocalReport.DataSources.Add(rds);


                    Utility.Slip_Log(rv);
                    //switch (_defaultPrinter)
                    //{

                    //    case "Slip Printer":
                    //        Utility.Slip_A4_Footer(rv);
                    //        break;
                    //}
                    Utility.Slip_A4_Footer(rv);
                    APP_Data.Customer cus = entity.Customers.Where(x => x.Id == CustomerId).FirstOrDefault();

                    ReportParameter CustomerName = new ReportParameter("CustomerName", cus.Name);
                    rv.LocalReport.SetParameters(CustomerName);

                    if (Convert.ToInt32(transactionObj.MCDiscountAmt) != 0)
                    {
                        _mcDiscountAmt = Convert.ToInt64(transactionObj.MCDiscountAmt);
                        ReportParameter MCDiscountAmt = new ReportParameter("MCDiscount", "-" + _mcDiscountAmt.ToString());
                        rv.LocalReport.SetParameters(MCDiscountAmt);
                    }

                    else if (Convert.ToInt32(transactionObj.BDDiscountAmt) != 0)
                    {
                        _bcDiscountAmt = Convert.ToInt64(transactionObj.BDDiscountAmt);
                        ReportParameter BCDiscountAmt = new ReportParameter("MCDiscount", "-" + _bcDiscountAmt.ToString());
                        rv.LocalReport.SetParameters(BCDiscountAmt);
                    }
                    else
                    {
                        ReportParameter BCDiscountAmt = new ReportParameter("MCDiscount", "0");
                        rv.LocalReport.SetParameters(BCDiscountAmt);
                    }
                    //string _tAmt1 = string.Format("{0:#,##0.00}", _tAmt);
                    //ReportParameter TAmt = new ReportParameter("TAmt", _tAmt1);
                    //rv.LocalReport.SetParameters(TAmt);
                    ReportParameter TAmt = new ReportParameter("TAmt", _tAmt.ToString());
                    rv.LocalReport.SetParameters(TAmt);
                    if (SettingController.SelectDefaultPrinter!="Slip Printer")
                    {
                        ReportParameter PrintProductImage = new ReportParameter("PrintImage", SettingController.ShowProductImageIn_A4Reports.ToString());
                        rv.LocalReport.SetParameters(PrintProductImage);
                    }
                 
                    if (transactionObj.Note.ToString() == "")
                    {
                        ReportParameter Notes = new ReportParameter("Notes", "");
                        rv.LocalReport.SetParameters(Notes);
                    }
                    else
                    {
                        ReportParameter Notes = new ReportParameter("Notes", transactionObj.Note.ToString());
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

                    ReportParameter TotalGiftDiscount = new ReportParameter("TotalGiftDiscount", transactionObj.MCDiscountAmt.ToString());
                    rv.LocalReport.SetParameters(TotalGiftDiscount);

                    ReportParameter TransactionId = new ReportParameter("TransactionId", transactionId.ToString());
                    rv.LocalReport.SetParameters(TransactionId);

                    APP_Data.Counter c = entity.Counters.FirstOrDefault(x => x.Id == MemberShip.CounterId);

                    ReportParameter CounterName = new ReportParameter("CounterName", c.Name);
                    rv.LocalReport.SetParameters(CounterName);

                    ReportParameter PrintDateTime = new ReportParameter();
                    switch (Utility.GetDefaultPrinter())
                    {
                        case "A4 Printer":
                            PrintDateTime = new ReportParameter("PrintDateTime", Convert.ToDateTime(transactionObj.DateTime).ToString("dd-MMM-yyyy"));
                            rv.LocalReport.SetParameters(PrintDateTime);
                            break;
                        case "Slip Printer":
                            PrintDateTime = new ReportParameter("PrintDateTime", Convert.ToDateTime(transactionObj.DateTime).ToString("dd/MM/yyyy hh:mm"));
                            rv.LocalReport.SetParameters(PrintDateTime);
                            break;
                    }

                    ReportParameter CasherName = new ReportParameter("CasherName", MemberShip.UserName);
                    rv.LocalReport.SetParameters(CasherName);

                    //ReportParameter TotalAmount = new ReportParameter("TotalAmount", transactionObj.TotalAmount.ToString()); //Edit By ZMH
                    //rv.LocalReport.SetParameters(TotalAmount);
                    //Int64 totalAmountRep = transactionObj.TotalAmount == null ? 0 : Convert.ToInt64(transactionObj.TotalAmount);
                    toalDiscAmt = Convert.ToInt32(transactionObj.DiscountAmount) - Convert.ToInt32(_refundDiscountamt) - _refundItemDiscAmt;
                    int taxamt = Convert.ToInt32(transactionObj.TaxAmount);
                    totalAmountRep = (_tAmt - _bcDiscountAmt - _mcDiscountAmt - toalDiscAmt) + taxamt;
                    ReportParameter TotalAmount = new ReportParameter("TotalAmount", (totalAmountRep+(totalAmountRep*transactionObj.ServiceFee/100)).ToString());
                    rv.LocalReport.SetParameters(TotalAmount);

                    ReportParameter TaxAmount = new ReportParameter("TaxAmount", transactionObj.TaxAmount.ToString());
                    rv.LocalReport.SetParameters(TaxAmount);

                    if (toalDiscAmt == 0)
                    {
                        ReportParameter DiscountAmount = new ReportParameter("DiscountAmount", toalDiscAmt.ToString());
                        rv.LocalReport.SetParameters(DiscountAmount);
                    }
                    else
                    {
                        ReportParameter DiscountAmount = new ReportParameter("DiscountAmount", "-" + toalDiscAmt.ToString());
                        rv.LocalReport.SetParameters(DiscountAmount);
                    }
                    ReportParameter PaidAmount = new ReportParameter("PaidAmount", transactionObj.RecieveAmount.ToString());
                    rv.LocalReport.SetParameters(PaidAmount);

                    //  ReportParameter Change = new ReportParameter("Change",(transactionObj.RecieveAmount - (transactionObj.TotalAmount - ExtraDiscount + ExtraTax)).ToString());//(amount - (DetailList.Sum(x => x.TotalAmount) - ExtraDiscount + ExtraTax))
                    ReportParameter Change = new ReportParameter("Change", (transactionObj.RecieveAmount - (totalAmountRep+(totalAmountRep* SettingController.ServiceFee / 100))).ToString());//(amount - (DetailList.Sum(x => x.TotalAmount) - ExtraDiscount + ExtraTax))
                    rv.LocalReport.SetParameters(Change);

                 

                    if (SettingController.UseTable || SettingController.UseQueue)
                    {
                        bool IsRestaurant = SettingController.UseTable ? SettingController.UseTable : SettingController.UseQueue ? SettingController.UseQueue : false;
                        ReportParameter restaurant = new ReportParameter("IsRestaurant", IsRestaurant.ToString());
                        rv.LocalReport.SetParameters(restaurant);
                        ReportParameter tblORque = new ReportParameter("TBLorQue", SettingController.UseTable && transactionObj.TableIdOrQue != null ? "# : " + entity.RestaurantTables.Find(transactionObj.TableIdOrQue).Number
                                                                       : SettingController.UseQueue && transactionObj.TableIdOrQue != null ? "# : " + transactionObj.TableIdOrQue.ToString().PadLeft(4, '0') : null);
                        rv.LocalReport.SetParameters(tblORque);
                            ReportParameter servicepercent = new ReportParameter("ServicePercent", transactionObj.ServiceFee.ToString());
                            rv.LocalReport.SetParameters(servicepercent);
                            ReportParameter servicecharge = new ReportParameter("ServiceFee", ((transactionObj.TransactionDetails.Sum(a=>a.TotalAmount))* transactionObj.ServiceFee/100).ToString());
                        rv.LocalReport.SetParameters(servicecharge);
                    }

                    if (Utility.GetDefaultPrinter() == "A4 Printer")
                    {
                        ReportParameter CusAddress = new ReportParameter("CusAddress", cus.Address);
                        rv.LocalReport.SetParameters(CusAddress);
                    }

                   var b =rv.LocalReport.GetParameters();
                    foreach (var item in b)
                    {
                      
                    }

                    ////       PrintDoc.PrintReport(rv, Utility.GetDefaultPrinter());
                    //PrintDoc.PrintReport(rv, "Slip");
                    Utility.Get_Print(rv);
                }
                else
                {
                    MessageBox.Show("Invoice No." + tranId + "  is already made refund all items.", "mPOS");
                }
                #endregion
            }
            else if (transactionObj.PaymentTypeId >= 501)
            {
                #region [ Print ] for MPU


                dsReportTemp dsReport = new dsReportTemp();
                dsReportTemp.ItemListDataTable dtReport = (dsReportTemp.ItemListDataTable)dsReport.Tables["ItemList"];
                //List<TransactionDetail> _tdList = (from td in transactionObj.TransactionDetails where td.IsDeleted == false select td).ToList();

                foreach (TransactionDetail transaction in _tdList)
                {
                    dsReportTemp.ItemListRow newRow = dtReport.NewItemListRow();
                    newRow.Name = transaction.Product.Name;
                    newRow.Qty = transaction.Qty.ToString();
                    newRow.PhotoPath = string.IsNullOrEmpty(transaction.Product.PhotoPath) ? "" : Application.StartupPath + transaction.Product.PhotoPath.Remove(0, 1);
                    //newRow.TotalAmount = (int)transaction.TotalAmount; //Edit By ZMH
                    newRow.DiscountPercent = transaction.DiscountRate.ToString();
                    newRow.TotalAmount = (int)transaction.UnitPrice * (int)transaction.Qty; //Edit By ZMH

                    if (transaction.IsFOC == true)
                    {
                        newRow.IsFOC = "FOC";
                    }

                    switch (Utility.GetDefaultPrinter())
                    {
                        case "A4 Printer":
                            newRow.UnitPrice = transaction.UnitPrice.ToString();
                            break;
                        case "Slip Printer":
                            newRow.UnitPrice = "1@" + transaction.UnitPrice.ToString();
                            break;
                    }


                    _tAmt += newRow.TotalAmount;

                    dtReport.AddItemListRow(newRow);
                    //   unitpriceTotalCost = (int)transaction.UnitPrice * (int)transaction.Qty;
                }

                if (dtReport.Count > 0)
                {
                    string reportPath = "";
                    ReportViewer rv = new ReportViewer();
                    ReportDataSource rds = new ReportDataSource("DataSet1", dsReport.Tables["ItemList"]);
                    reportPath = Application.StartupPath + Utility.GetReportPath("MPU");
                    rv.Reset();
                    rv.LocalReport.ReportPath = reportPath;
                    rv.LocalReport.DataSources.Add(rds);

                    Utility.Slip_Log(rv);
                    ////switch (_defaultPrinter)
                    ////{

                    ////    case "Slip Printer":
                    ////        Utility.Slip_A4_Footer(rv);
                    ////        break;
                    ////}

                    Utility.Slip_A4_Footer(rv);

                    APP_Data.Customer cus = entity.Customers.Where(x => x.Id == CustomerId).FirstOrDefault();

                    ReportParameter CustomerName = new ReportParameter("CustomerName", cus.Name);
                    rv.LocalReport.SetParameters(CustomerName);

                    if (Convert.ToInt32(transactionObj.MCDiscountAmt) != 0)
                    {
                        _mcDiscountAmt = Convert.ToInt64(transactionObj.MCDiscountAmt);
                        ReportParameter MCDiscountAmt = new ReportParameter("MCDiscount", "-" + _mcDiscountAmt.ToString());
                        rv.LocalReport.SetParameters(MCDiscountAmt);
                    }

                    else if (Convert.ToInt32(transactionObj.BDDiscountAmt) != 0)
                    {
                        _bcDiscountAmt = Convert.ToInt64(transactionObj.BDDiscountAmt);
                        ReportParameter BCDiscountAmt = new ReportParameter("MCDiscount", "-" + _bcDiscountAmt.ToString());
                        rv.LocalReport.SetParameters(BCDiscountAmt);
                    }
                    else
                    {
                        ReportParameter BCDiscountAmt = new ReportParameter("MCDiscount", "0");
                        rv.LocalReport.SetParameters(BCDiscountAmt);
                    }

                    ReportParameter TAmt = new ReportParameter("TAmt", _tAmt.ToString());
                    rv.LocalReport.SetParameters(TAmt);
                    if (SettingController.SelectDefaultPrinter != "Slip Printer")
                    {
                        ReportParameter PrintProductImage = new ReportParameter("PrintImage", SettingController.ShowProductImageIn_A4Reports.ToString());
                        rv.LocalReport.SetParameters(PrintProductImage);
                    }
                    if (transactionObj.Note.ToString() == "")
                    {
                        ReportParameter Notes = new ReportParameter("Notes", " ");
                        rv.LocalReport.SetParameters(Notes);
                    }
                    else
                    {
                        ReportParameter Notes = new ReportParameter("Notes", transactionObj.Note.ToString());
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

                    ReportParameter TotalGiftDiscount = new ReportParameter("TotalGiftDiscount", transactionObj.MCDiscountAmt.ToString());
                    rv.LocalReport.SetParameters(TotalGiftDiscount);

                    ReportParameter TransactionId = new ReportParameter("TransactionId", transactionId.ToString());
                    rv.LocalReport.SetParameters(TransactionId);

                    APP_Data.Counter c = entity.Counters.FirstOrDefault(x => x.Id == MemberShip.CounterId);

                    ReportParameter CounterName = new ReportParameter("CounterName", c.Name);
                    rv.LocalReport.SetParameters(CounterName);
                    ReportParameter PrintDateTime = new ReportParameter();
                    switch (Utility.GetDefaultPrinter())
                    {
                        case "A4 Printer":
                            PrintDateTime = new ReportParameter("PrintDateTime", Convert.ToDateTime(transactionObj.DateTime).ToString("dd-MMM-yyyy"));
                            rv.LocalReport.SetParameters(PrintDateTime);
                            break;
                        case "Slip Printer":
                            PrintDateTime = new ReportParameter("PrintDateTime", Convert.ToDateTime(transactionObj.DateTime).ToString("dd/MM/yyyy hh:mm"));
                            rv.LocalReport.SetParameters(PrintDateTime);
                            break;
                    }


                    ReportParameter CasherName = new ReportParameter("CasherName", MemberShip.UserName);
                    rv.LocalReport.SetParameters(CasherName);


                    totalAmountRep = (_tAmt + _bcDiscountAmt + _mcDiscountAmt - Convert.ToInt32(transactionObj.DiscountAmount));
                    ReportParameter TotalAmount = new ReportParameter("TotalAmount", (totalAmountRep + (totalAmountRep * transactionObj.ServiceFee / 100)).ToString());
                    rv.LocalReport.SetParameters(TotalAmount);

                    ReportParameter TaxAmount = new ReportParameter("TaxAmount", transactionObj.TaxAmount.ToString());
                    rv.LocalReport.SetParameters(TaxAmount);

                    ReportParameter BankPayment = new ReportParameter("BankPayment", transactionObj.PaymentType.Name.ToString());
                    rv.LocalReport.SetParameters(BankPayment);

                    if (Convert.ToInt32(transactionObj.DiscountAmount) == 0)
                    {
                        ReportParameter DiscountAmount = new ReportParameter("DiscountAmount", transactionObj.DiscountAmount.ToString());
                        rv.LocalReport.SetParameters(DiscountAmount);
                    }
                    else
                    {
                        ReportParameter DiscountAmount = new ReportParameter("DiscountAmount", "-" + transactionObj.DiscountAmount.ToString());
                        rv.LocalReport.SetParameters(DiscountAmount);
                    }

                    ReportParameter PaidAmount = new ReportParameter("PaidAmount", transactionObj.RecieveAmount.ToString());
                    rv.LocalReport.SetParameters(PaidAmount);

                    ReportParameter Change = new ReportParameter("Change", "0");//(amount - (DetailList.Sum(x => x.TotalAmount) - ExtraDiscount + ExtraTax))
                    rv.LocalReport.SetParameters(Change);
                   

                    if (SettingController.UseTable || SettingController.UseQueue)
                    {
                        bool IsRestaurant = SettingController.UseTable ? SettingController.UseTable : SettingController.UseQueue ? SettingController.UseQueue : false;
                        ReportParameter restaurant = new ReportParameter("IsRestaurant", IsRestaurant.ToString());
                        rv.LocalReport.SetParameters(restaurant);
                        ReportParameter tblORque = new ReportParameter("TBLorQue", SettingController.UseTable && transactionObj.TableIdOrQue != null ? "# : " + entity.RestaurantTables.Find(transactionObj.TableIdOrQue).Number
                                                                        : SettingController.UseQueue && transactionObj.TableIdOrQue != null ? "# : " + transactionObj.TableIdOrQue.ToString().PadLeft(4, '0') : null);
                        rv.LocalReport.SetParameters(tblORque);
                        ReportParameter servicepercent = new ReportParameter("ServicePercent", transactionObj.ServiceFee.ToString());
                        rv.LocalReport.SetParameters(servicepercent);
                        ReportParameter servicecharge = new ReportParameter("ServiceFee", ((transactionObj.TransactionDetails.Sum(a => a.TotalAmount)) * transactionObj.ServiceFee / 100).ToString());
                        rv.LocalReport.SetParameters(servicecharge);
                    }

                    if (Utility.GetDefaultPrinter() == "A4 Printer")
                    {
                        ReportParameter CusAddress = new ReportParameter("CusAddress", transactionObj.Customer.Address);
                        rv.LocalReport.SetParameters(CusAddress);
                    }


                    ////  PrintDoc.PrintReport(rv, Utility.GetDefaultPrinter());
                    Utility.Get_Print(rv);
                }
                else
                {
                    MessageBox.Show("Invoice No." + tranId + "  is already made refund all items.", "mPOS");
                }
                #endregion
            }

            else if (transactionObj.PaymentTypeId == 4)
            {
                #region [ Print ] for FOC


                dsReportTemp dsReport = new dsReportTemp();
                dsReportTemp.ItemListDataTable dtReport = (dsReportTemp.ItemListDataTable)dsReport.Tables["ItemList"];
                //List<TransactionDetail> _tdList = (from td in transactionObj.TransactionDetails where td.IsDeleted == false select td).ToList();

                foreach (TransactionDetail transaction in _tdList)
                {
                    dsReportTemp.ItemListRow newRow = dtReport.NewItemListRow();
                    newRow.Name = transaction.Product.Name;
                    newRow.Qty = transaction.Qty.ToString();
                    newRow.PhotoPath = string.IsNullOrEmpty(transaction.Product.PhotoPath) ? "" : Application.StartupPath + transaction.Product.PhotoPath.Remove(0, 1);
                    //newRow.TotalAmount = (int)transaction.TotalAmount; //Edit By ZMH
                    newRow.DiscountPercent = transaction.DiscountRate.ToString();
                    newRow.TotalAmount = (int)transaction.UnitPrice * (int)transaction.Qty; //Edit By ZMH
                    switch (Utility.GetDefaultPrinter())
                    {
                        case "A4 Printer":
                            //newRow.UnitPrice = transaction.UnitPrice.ToString();
                            newRow.UnitPrice = transaction.SellingPrice.ToString();
                            break;
                        case "Slip Printer":
                            //  newRow.UnitPrice = "1@" + transaction.UnitPrice.ToString();
                            newRow.UnitPrice = "1@" + transaction.SellingPrice.ToString();
                            break;
                    }

                    _tAmt += newRow.TotalAmount;

                    dtReport.AddItemListRow(newRow);
                }

                if (dtReport.Count > 0)
                {
                    string reportPath = "";
                    ReportViewer rv = new ReportViewer();
                    ReportDataSource rds = new ReportDataSource("DataSet1", dsReport.Tables["ItemList"]);
                    reportPath = Application.StartupPath + Utility.GetReportPath("FOC");
                    rv.Reset();
                    rv.LocalReport.ReportPath = reportPath;
                    rv.LocalReport.DataSources.Add(rds);

                    Utility.Slip_Log(rv);
                    //switch (_defaultPrinter)
                    //{

                    //    case "Slip Printer":
                    //        Utility.Slip_A4_Footer(rv);
                    //        break;
                    //}
                    Utility.Slip_A4_Footer(rv);

                    APP_Data.Customer cus = entity.Customers.Where(x => x.Id == CustomerId).FirstOrDefault();

                    ReportParameter CustomerName = new ReportParameter("CustomerName", cus.Name);
                    rv.LocalReport.SetParameters(CustomerName);

                    if (Convert.ToInt32(transactionObj.MCDiscountAmt) != 0)
                    {
                        _mcDiscountAmt = Convert.ToInt64(transactionObj.MCDiscountAmt);
                        ReportParameter MCDiscountAmt = new ReportParameter("MCDiscount", "-" + _mcDiscountAmt.ToString());
                        rv.LocalReport.SetParameters(MCDiscountAmt);
                    }

                    else if (Convert.ToInt32(transactionObj.BDDiscountAmt) != 0)
                    {
                        _bcDiscountAmt = Convert.ToInt64(transactionObj.BDDiscountAmt);
                        ReportParameter BCDiscountAmt = new ReportParameter("MCDiscount", "-" + _bcDiscountAmt.ToString());
                        rv.LocalReport.SetParameters(BCDiscountAmt);
                    }
                    else
                    {
                        ReportParameter BCDiscountAmt = new ReportParameter("MCDiscount", "0");
                        rv.LocalReport.SetParameters(BCDiscountAmt);
                    }

                    ReportParameter TAmt = new ReportParameter("TAmt", _tAmt.ToString());
                    rv.LocalReport.SetParameters(TAmt);
                    if (SettingController.SelectDefaultPrinter != "Slip Printer")
                    {
                        ReportParameter PrintProductImage = new ReportParameter("PrintImage", SettingController.ShowProductImageIn_A4Reports.ToString());
                        rv.LocalReport.SetParameters(PrintProductImage);
                    }
                    if (transactionObj.Note.ToString() == "")
                    {
                        ReportParameter Notes = new ReportParameter("Notes", " ");
                        rv.LocalReport.SetParameters(Notes);
                    }
                    else
                    {
                        ReportParameter Notes = new ReportParameter("Notes", transactionObj.Note.ToString());
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

                    ReportParameter TransactionId = new ReportParameter("TransactionId", transactionId.ToString());
                    rv.LocalReport.SetParameters(TransactionId);

                    APP_Data.Counter c = entity.Counters.FirstOrDefault(x => x.Id == MemberShip.CounterId);

                    ReportParameter CounterName = new ReportParameter("CounterName", c.Name);
                    rv.LocalReport.SetParameters(CounterName);

                    ReportParameter PrintDateTime = new ReportParameter();
                    switch (Utility.GetDefaultPrinter())
                    {
                        case "A4 Printer":
                            PrintDateTime = new ReportParameter("PrintDateTime", Convert.ToDateTime(transactionObj.DateTime).ToString("dd-MMM-yyyy"));
                            rv.LocalReport.SetParameters(PrintDateTime);
                            break;
                        case "Slip Printer":
                            PrintDateTime = new ReportParameter("PrintDateTime", Convert.ToDateTime(transactionObj.DateTime).ToString("dd/MM/yyyy hh:mm"));
                            rv.LocalReport.SetParameters(PrintDateTime);
                            break;
                    }

                    ReportParameter CasherName = new ReportParameter("CasherName", MemberShip.UserName);
                    rv.LocalReport.SetParameters(CasherName);

                    totalAmountRep = (_tAmt + _bcDiscountAmt + _mcDiscountAmt - Convert.ToInt32(transactionObj.DiscountAmount));
                    ReportParameter TotalAmount = new ReportParameter("TotalAmount", (totalAmountRep + (totalAmountRep * transactionObj.ServiceFee / 100)).ToString());
                    rv.LocalReport.SetParameters(TotalAmount);

                    ReportParameter TaxAmount = new ReportParameter("TaxAmount", transactionObj.TaxAmount.ToString());
                    rv.LocalReport.SetParameters(TaxAmount);

                    if (Convert.ToInt32(transactionObj.DiscountAmount) == 0)
                    {
                        ReportParameter DiscountAmount = new ReportParameter("DiscountAmount", Convert.ToInt32(transactionObj.DiscountAmount).ToString());
                        rv.LocalReport.SetParameters(DiscountAmount);
                    }
                    else
                    {
                        ReportParameter DiscountAmount = new ReportParameter("DiscountAmount", "-" + Convert.ToInt32(transactionObj.DiscountAmount).ToString());
                        rv.LocalReport.SetParameters(DiscountAmount);
                    }

                    ReportParameter PaidAmount = new ReportParameter("PaidAmount", transactionObj.RecieveAmount.ToString());
                    rv.LocalReport.SetParameters(PaidAmount);

                    //ReportParameter Change = new ReportParameter("Change", (transactionObj.RecieveAmount - (transactionObj.TotalAmount - ExtraDiscount + ExtraTax)).ToString());//(amount - (DetailList.Sum(x => x.TotalAmount) - ExtraDiscount + ExtraTax))
                    ReportParameter Change = new ReportParameter("Change", "0");//(amount - (DetailList.Sum(x => x.TotalAmount) - ExtraDiscount + ExtraTax))
                    rv.LocalReport.SetParameters(Change);

                    if (Utility.GetDefaultPrinter() == "A4 Printer")
                    {
                        ReportParameter CusAddress = new ReportParameter("CusAddress", transactionObj.Customer.Address);
                        rv.LocalReport.SetParameters(CusAddress);
                    }
                    //// PrintDoc.PrintReport(rv, Utility.GetDefaultPrinter());
                    Utility.Get_Print(rv);
                }
                else
                {
                    MessageBox.Show("Invoice No." + tranId + "  is already made refund all items.", "mPOS");
                }
                #endregion
            }
            else if (transactionObj.PaymentTypeId == 6)
            {
                #region [ Print ] for Tester


                dsReportTemp dsReport = new dsReportTemp();
                dsReportTemp.ItemListDataTable dtReport = (dsReportTemp.ItemListDataTable)dsReport.Tables["ItemList"];
                //List<TransactionDetail> _tdList = (from td in transactionObj.TransactionDetails where td.IsDeleted == false select td).ToList();

                foreach (TransactionDetail transaction in _tdList)
                {
                    dsReportTemp.ItemListRow newRow = dtReport.NewItemListRow();
                    newRow.Name = transaction.Product.Name;
                    newRow.Qty = transaction.Qty.ToString();
                    newRow.PhotoPath = string.IsNullOrEmpty(transaction.Product.PhotoPath) ? "" : Application.StartupPath + transaction.Product.PhotoPath.Remove(0, 1);

                 
                    //newRow.TotalAmount = (int)transaction.TotalAmount; //Edit By ZMH
                    newRow.DiscountPercent = transaction.DiscountRate.ToString();
                    newRow.TotalAmount = (int)transaction.UnitPrice * (int)transaction.Qty; //Edit By ZMH
                    switch (Utility.GetDefaultPrinter())
                    {
                        case "A4 Printer":
                            newRow.UnitPrice = transaction.UnitPrice.ToString();
                            break;
                        case "Slip Printer":
                            newRow.UnitPrice = "1@" + transaction.UnitPrice.ToString();
                            break;
                    }

                    _tAmt += newRow.TotalAmount;

                    dtReport.AddItemListRow(newRow);
                }

                if (dtReport.Count > 0)
                {
                    string reportPath = "";
                    ReportViewer rv = new ReportViewer();
                    ReportDataSource rds = new ReportDataSource("DataSet1", dsReport.Tables["ItemList"]);
                    reportPath = Application.StartupPath + Utility.GetReportPath("Tester");
                    rv.Reset();
                    rv.LocalReport.ReportPath = reportPath;
                    rv.LocalReport.DataSources.Add(rds);

                    Utility.Slip_Log(rv);
                    ////switch (_defaultPrinter)
                    ////{

                    ////    case "Slip Printer":
                    ////        Utility.Slip_A4_Footer(rv);
                    ////        break;
                    ////}

                    Utility.Slip_A4_Footer(rv);

                    APP_Data.Customer cus = entity.Customers.Where(x => x.Id == CustomerId).FirstOrDefault();

                    ReportParameter CustomerName = new ReportParameter("CustomerName", cus.Name);
                    rv.LocalReport.SetParameters(CustomerName);

                    if (Convert.ToInt32(transactionObj.MCDiscountAmt) != 0)
                    {
                        _mcDiscountAmt = Convert.ToInt64(transactionObj.MCDiscountAmt);
                        ReportParameter MCDiscountAmt = new ReportParameter("MCDiscount", "-" + _mcDiscountAmt.ToString());
                        rv.LocalReport.SetParameters(MCDiscountAmt);
                    }

                    else if (Convert.ToInt32(transactionObj.BDDiscountAmt) != 0)
                    {
                        _bcDiscountAmt = Convert.ToInt64(transactionObj.BDDiscountAmt);
                        ReportParameter BCDiscountAmt = new ReportParameter("MCDiscount", "-" + _bcDiscountAmt.ToString());
                        rv.LocalReport.SetParameters(BCDiscountAmt);
                    }
                    else
                    {
                        ReportParameter BCDiscountAmt = new ReportParameter("MCDiscount", "0");
                        rv.LocalReport.SetParameters(BCDiscountAmt);
                    }


                    ReportParameter Title = new ReportParameter("Title", "TESTER SALE INVOICE");
                    rv.LocalReport.SetParameters(Title);

                    ReportParameter TAmt = new ReportParameter("TAmt", _tAmt.ToString());
                    rv.LocalReport.SetParameters(TAmt);
                    if (SettingController.SelectDefaultPrinter != "Slip Printer")
                    {
                        ReportParameter PrintProductImage = new ReportParameter("PrintImage", SettingController.ShowProductImageIn_A4Reports.ToString());
                        rv.LocalReport.SetParameters(PrintProductImage);
                    }
                    if (transactionObj.Note.ToString() == "")
                    {
                        ReportParameter Notes = new ReportParameter("Notes", " ");
                        rv.LocalReport.SetParameters(Notes);
                    }
                    else
                    {
                        ReportParameter Notes = new ReportParameter("Notes", transactionObj.Note.ToString());
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

                    ReportParameter TransactionId = new ReportParameter("TransactionId", transactionId.ToString());
                    rv.LocalReport.SetParameters(TransactionId);

                    APP_Data.Counter c = entity.Counters.FirstOrDefault(x => x.Id == MemberShip.CounterId);

                    ReportParameter CounterName = new ReportParameter("CounterName", c.Name);
                    rv.LocalReport.SetParameters(CounterName);

                    ReportParameter PrintDateTime = new ReportParameter();
                    switch (Utility.GetDefaultPrinter())
                    {
                        case "A4 Printer":
                            PrintDateTime = new ReportParameter("PrintDateTime", Convert.ToDateTime(transactionObj.DateTime).ToString("dd-MMM-yyyy"));
                            rv.LocalReport.SetParameters(PrintDateTime);
                            break;
                        case "Slip Printer":
                            PrintDateTime = new ReportParameter("PrintDateTime", Convert.ToDateTime(transactionObj.DateTime).ToString("dd/MM/yyyy hh:mm"));
                            rv.LocalReport.SetParameters(PrintDateTime);
                            break;
                    }

                    ReportParameter CasherName = new ReportParameter("CasherName", MemberShip.UserName);
                    rv.LocalReport.SetParameters(CasherName);

                    totalAmountRep = (_tAmt + _bcDiscountAmt + _mcDiscountAmt - Convert.ToInt32(transactionObj.DiscountAmount));
                    ReportParameter TotalAmount = new ReportParameter("TotalAmount", (totalAmountRep + (totalAmountRep * transactionObj.ServiceFee / 100)).ToString());
                    rv.LocalReport.SetParameters(TotalAmount);

                    ReportParameter TaxAmount = new ReportParameter("TaxAmount", transactionObj.TaxAmount.ToString());
                    rv.LocalReport.SetParameters(TaxAmount);

                    if (Convert.ToInt32(transactionObj.DiscountAmount) == 0)
                    {
                        ReportParameter DiscountAmount = new ReportParameter("DiscountAmount", Convert.ToInt32(transactionObj.DiscountAmount).ToString());
                        rv.LocalReport.SetParameters(DiscountAmount);
                    }
                    else
                    {
                        ReportParameter DiscountAmount = new ReportParameter("DiscountAmount", "-" + Convert.ToInt32(transactionObj.DiscountAmount).ToString());
                        rv.LocalReport.SetParameters(DiscountAmount);
                    }

                    ReportParameter PaidAmount = new ReportParameter("PaidAmount", transactionObj.RecieveAmount.ToString());
                    rv.LocalReport.SetParameters(PaidAmount);

                    //ReportParameter Change = new ReportParameter("Change", (transactionObj.RecieveAmount - (transactionObj.TotalAmount - ExtraDiscount + ExtraTax)).ToString());//(amount - (DetailList.Sum(x => x.TotalAmount) - ExtraDiscount + ExtraTax))
                    ReportParameter Change = new ReportParameter("Change", "0");//(amount - (DetailList.Sum(x => x.TotalAmount) - ExtraDiscount + ExtraTax))
                    rv.LocalReport.SetParameters(Change);

                    if (Utility.GetDefaultPrinter() == "A4 Printer")
                    {
                        ReportParameter CusAddress = new ReportParameter("CusAddress", transactionObj.Customer.Address);
                        rv.LocalReport.SetParameters(CusAddress);
                    }
                    ////PrintDoc.PrintReport(rv, Utility.GetDefaultPrinter());
                    Utility.Get_Print(rv);
                }
                else
                {
                    MessageBox.Show("Invoice No." + tranId + "  is already made refund all items.", "mPOS");
                }
                #endregion
            }
        }

        private void dgvTransactionDetail_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0)
            {
                int currentTransactionId = Convert.ToInt32(dgvTransactionDetail.Rows[e.RowIndex].Cells[9].Value.ToString());
                bool IsSame = false;
                //Delete the record and add delete log
                if (e.ColumnIndex == 11)
                {
                    if(dgvTransactionDetail.Rows[e.RowIndex].Cells[2].Value.ToString() ==dgvTransactionDetail.Rows[e.RowIndex].Cells[3].Value.ToString())
                    {
                         dgvTransactionDetail.Rows[e.RowIndex].Cells[11].ReadOnly = true;
                        return;
                    }

                    if (!DeleteLink)
                    {
                        dgvTransactionDetail.Rows[e.RowIndex].Cells[11].ReadOnly = true;
                        return;
                    }

                    APP_Data.TransactionDetail tdOBj = new TransactionDetail();
                    APP_Data.Transaction tObj = new Transaction();

                    DialogResult result = MessageBox.Show("Are you sure you want to delete?", "Delete", MessageBoxButtons.OKCancel, MessageBoxIcon.Information);
                    if (result.Equals(DialogResult.OK))
                    {
                        tdOBj = entity.TransactionDetails.Where(x => x.Id == currentTransactionId).FirstOrDefault();
                     APP_Data.TransactionDetail  _isConsignmentPaidTranList = entity.TransactionDetails.Where(x => x.Id == currentTransactionId && x.IsDeleted == false && x.IsConsignmentPaid == true).FirstOrDefault();
                        if (tdOBj != null)
                        {
                            tObj = entity.Transactions.Where(x => x.ParentId == tdOBj.TransactionId && x.IsDeleted == false).FirstOrDefault();
                        }
                        if (tObj != null)
                        {
                          // TransactionDetail td = entity.TransactionDetails.Where(x => x.TransactionId == tObj.Id).FirstOrDefault();
                            string proCode=dgvTransactionDetail.Rows[e.RowIndex].Cells[0].Value.ToString();

                            var proId = entity.Products.Where(x => x.ProductCode == proCode).Select(x => x.Id).FirstOrDefault();
                            List<TransactionDetail> td = entity.TransactionDetails.Where(x => x.TransactionId == tObj.Id && x.ProductId == proId).ToList();
                            if (td.Count > 0)
                            {
                                //if (td.ProductId == tdOBj.ProductId)
                                //{
                                    IsSame = true;
                              //  }
                            }
                        }
                        if (IsSame)
                        {
                            MessageBox.Show("This transaction detail already made refund. So it can't be delete!");
                            return;
                        }
                        else if (_isConsignmentPaidTranList != null)
                        {
                            MessageBox.Show("This transaction detail already made  Consignment Settlement. So it can't be delete!");
                            return;
                        }
                        else
                        {
                            if (dgvTransactionDetail.Rows.Count <= 1)
                            {
                                DialogResult result2 = MessageBox.Show("You have only one record!.If you delete this,system will automatically delete Transaction of this record", "Delete", MessageBoxButtons.OKCancel, MessageBoxIcon.Information);
                                if (result2.Equals(DialogResult.OK))
                                {
                                    TransactionDetail ts = entity.TransactionDetails.Where(x => x.Id == currentTransactionId).FirstOrDefault();
                                    Transaction t = entity.Transactions.Where(x => x.Id == ts.TransactionId).FirstOrDefault();
                                    

                                    if (t.GiftCardId != null && t.GiftCard != null)
                                    {
                                        t.GiftCard.Amount = t.GiftCard.Amount + Convert.ToInt32(t.GiftCardAmount);
                                    }
                                    t.IsDeleted = true;
                                    foreach (TransactionDetail td in t.TransactionDetails)
                                    {
                                        //td.IsDeleted = false;
                                        td.IsDeleted = true;
                                    }

                               
                                    // update Prepaid Transaction id = false   and delete list in useprepaiddebt table
                                    Utility.Plus_PreaidAmt(t);

                                    ts.Product.Qty = ts.Product.Qty + ts.Qty;

                                    //save in stocktransaction

                                    Stock_Transaction st = new Stock_Transaction();
                                    st.ProductId = ts.Product.Id;
                                    Qty -= Convert.ToInt32(ts.Qty);
                                    st.Sale = Qty;
                                    productList.Add(st);
                                    Qty = 0;


                                    Save_SaleQty_ToStockTransaction(productList, date);
                                    productList.Clear();

                                    if (ts.Product.IsWrapper == true)
                                    {
                                        List<SPDetail> wList = ts.Product.SPDetails.Where(x => x.TransactionDetailID == ts.Id).ToList();
                                        if (wList.Count > 0)
                                        {
                                            foreach (SPDetail w in wList)
                                            {
                                                Product wpObj = (from p in entity.Products where p.Id == w.ChildProductID select p).FirstOrDefault();

                                                Stock_Transaction stwp = new Stock_Transaction();
                                                stwp.ProductId = w.ChildProductID;
                                                Qty -= Convert.ToInt32(w.ChildQty);
                                                stwp.Sale = Qty;
                                                productList.Add(stwp);

                                                Qty = 0;
                                                wpObj.Qty = wpObj.Qty + (w.ChildQty);
                                            }
                                        }
                                    }


                                    //modify delete (zp)
                                    #region Purchase Delete

                                    if (ts.Product.IsWrapper == true)
                                    {
                                        //ZP Get purchase detail with child product Id and order by purchase date ascending
                                        List<SPDetail> splist = ts.Product.SPDetails.Where(x => x.TransactionDetailID == ts.Id).ToList();
                                        foreach (SPDetail w in splist)
                                        {
                                            //  int qty = Convert.ToInt32(w.Qty);
                                            Product wpObj = (from p in entity.Products where p.Id == w.ChildProductID select p).FirstOrDefault();

                                            List<APP_Data.PurchaseDetailInTransaction> puInTranDetail = entity.PurchaseDetailInTransactions.Where(x => x.TransactionDetailId == ts.Id && x.ProductId == wpObj.Id).ToList();
                                            if (puInTranDetail.Count > 0)
                                            {
                                                foreach (PurchaseDetailInTransaction p in puInTranDetail)
                                                {
                                                    PurchaseDetail pud = entity.PurchaseDetails.Where(x => x.Id == p.PurchaseDetailId).FirstOrDefault();
                                                    if (pud != null)
                                                    {
                                                        pud.CurrentQy = pud.CurrentQy + p.Qty;
                                                    }
                                                    entity.Entry(pud).State = EntityState.Modified;
                                                    entity.SaveChanges();

                                                    //entity.PurchaseDetailInTransactions.Remove(p);
                                                    //entity.SaveChanges();

                                                    p.Qty = 0;
                                                    entity.Entry(p).State = EntityState.Modified;

                                                    entity.PurchaseDetailInTransactions.Remove(p);
                                                    entity.SaveChanges();
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                        List<APP_Data.PurchaseDetailInTransaction> puInTranDetail = entity.PurchaseDetailInTransactions.Where(x => x.TransactionDetailId == ts.Id && x.ProductId == ts.ProductId).ToList();
                                        if (puInTranDetail.Count > 0)
                                        {
                                            foreach (PurchaseDetailInTransaction p in puInTranDetail)
                                            {
                                                PurchaseDetail pud = entity.PurchaseDetails.Where(x => x.Id == p.PurchaseDetailId).FirstOrDefault();
                                                if (pud != null)
                                                {
                                                    pud.CurrentQy = pud.CurrentQy + p.Qty;
                                                }
                                                entity.Entry(pud).State = EntityState.Modified;
                                                entity.SaveChanges();

                                                //entity.PurchaseDetailInTransactions.Remove(p);
                                                //entity.SaveChanges();

                                                p.Qty = 0;
                                                entity.Entry(p).State = EntityState.Modified;

                                                entity.PurchaseDetailInTransactions.Remove(p);
                                                entity.SaveChanges();
                                            }
                                        }
                                    }


                                    #endregion

                                    //delete status at ticket
                                    Ticket ti = entity.Tickets.Where(x => x.TransactionDetailId == ts.Id).FirstOrDefault();
                                    if (ti!=null)
                                    {
                                        ti.isDelete = true;
                                        ti.DeletedDate = DateTime.Now;
                                        int uid = MemberShip.UserId;
                                        var cUser = entity.Users.Find(uid);
                                        ti.UserName = cUser.Name;
                                        entity.Entry(ti).State = EntityState.Modified;
                                        entity.SaveChanges();
                                    }
                                   


                                    DeleteLog dl = new DeleteLog();
                                    dl.DeletedDate = DateTime.Now;
                                    dl.CounterId = MemberShip.CounterId;
                                    dl.UserId = MemberShip.UserId;
                                    dl.IsParent = true;
                                    dl.TransactionId = t.Id;
                                    //dl.TransactionDetailId = ts.Id;

                             

                                    List<DeleteLog> delist = entity.DeleteLogs.Where(x => x.TransactionId == t.Id && x.TransactionDetailId != null && x.IsParent == false).ToList();

                                    foreach (DeleteLog d in delist)
                                    {
                                        entity.DeleteLogs.Remove(d);
                                    }
                                    entity.DeleteLogs.Add(dl);
                                    entity.SaveChanges();
                                    LoadData();
                                    this.Close();

                                    if (System.Windows.Forms.Application.OpenForms["TransactionList"] != null)
                                    {
                                        TransactionList newForm = (TransactionList)System.Windows.Forms.Application.OpenForms["TransactionList"];
                                        newForm.LoadData();
                                    }
                                }
                            }
                            else
                            {
                                TransactionDetail ts = entity.TransactionDetails.Where(x => x.Id == currentTransactionId).FirstOrDefault();
                                Transaction t = entity.Transactions.Where(x => x.Id == ts.TransactionId).FirstOrDefault();

                                ts.IsDeleted = true;

                                ts.Product.Qty = ts.Product.Qty + ts.Qty;

                                //save in stocktransaction

                                Stock_Transaction st = new Stock_Transaction();
                                st.ProductId = ts.Product.Id;
                                Qty -= Convert.ToInt32(ts.Qty);
                                st.Sale = Qty;
                                productList.Add(st);
                                Qty = 0;

                                Save_SaleQty_ToStockTransaction(productList, date);

                                if (ts.Product.IsWrapper == true)
                                {
                                    List<SPDetail> wList = ts.Product.SPDetails.Where(x=>x.TransactionDetailID==ts.Id).ToList();
                                    if (wList.Count > 0)
                                    {
                                        foreach (SPDetail w in wList)
                                        {
                                            Product wpObj = (from p in entity.Products where p.Id == w.ChildProductID select p).FirstOrDefault();

                                            Stock_Transaction stwp = new Stock_Transaction();
                                            stwp.ProductId = w.ChildProductID;
                                            Qty -= Convert.ToInt32(w.ChildQty);
                                            stwp.Sale = Qty;
                                            productList.Add(stwp);

                                            Qty = 0;
                                            wpObj.Qty = wpObj.Qty + (w.ChildQty);
                                        }
                                    }
                                }
                                DeleteLog dl = new DeleteLog();
                                dl.DeletedDate = DateTime.Now;
                                dl.CounterId = MemberShip.CounterId;
                                dl.UserId = MemberShip.UserId;
                                dl.IsParent = false;
                                dl.TransactionId = ts.TransactionId;
                                dl.TransactionDetailId = ts.Id;

                                Transaction ParentTransaction = entity.Transactions.Where(x => x.Id == ts.TransactionId).FirstOrDefault();
                                ParentTransaction.TotalAmount = ParentTransaction.TotalAmount - ts.TotalAmount;

                                int _disAmt = Convert.ToInt32((ts.UnitPrice / 100) * ts.DiscountRate);
                                ParentTransaction.DiscountAmount = Convert.ToInt32(ParentTransaction.DiscountAmount - _disAmt);

                                entity.DeleteLogs.Add(dl);
                                entity.SaveChanges();

                                //For Purchase 
                                #region Purchase Delete



                                if (ts.Product.IsWrapper == true)
                                {
                                    //ZP Get purchase detail with child product Id and order by purchase date ascending
                                    List<SPDetail> splist = ts.Product.SPDetails.Where(x => x.TransactionDetailID == ts.Id).ToList();
                                    foreach (SPDetail w in splist)
                                    {
                                        //  int qty = Convert.ToInt32(w.Qty);
                                        Product wpObj = (from p in entity.Products where p.Id == w.ChildProductID select p).FirstOrDefault();

                                        List<APP_Data.PurchaseDetailInTransaction> puInTranDetail = entity.PurchaseDetailInTransactions.Where(x => x.TransactionDetailId == ts.Id && x.ProductId == wpObj.Id).ToList();
                                        if (puInTranDetail.Count > 0)
                                        {
                                            foreach (PurchaseDetailInTransaction p in puInTranDetail)
                                            {
                                                PurchaseDetail pud = entity.PurchaseDetails.Where(x => x.Id == p.PurchaseDetailId).FirstOrDefault();
                                                if (pud != null)
                                                {
                                                    pud.CurrentQy = pud.CurrentQy + p.Qty;
                                                }
                                                entity.Entry(pud).State = EntityState.Modified;
                                                entity.SaveChanges();

                                                //entity.PurchaseDetailInTransactions.Remove(p);
                                                //entity.SaveChanges();

                                                p.Qty = 0;
                                                entity.Entry(p).State = EntityState.Modified;

                                                entity.PurchaseDetailInTransactions.Remove(p);
                                                entity.SaveChanges();
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    List<APP_Data.PurchaseDetailInTransaction> puInTranDetail = entity.PurchaseDetailInTransactions.Where(x => x.TransactionDetailId == ts.Id && x.ProductId == ts.ProductId).ToList();
                                    if (puInTranDetail.Count > 0)
                                    {
                                        foreach (PurchaseDetailInTransaction p in puInTranDetail)
                                        {
                                            PurchaseDetail pud = entity.PurchaseDetails.Where(x => x.Id == p.PurchaseDetailId).FirstOrDefault();
                                            if (pud != null)
                                            {
                                                pud.CurrentQy = pud.CurrentQy + p.Qty;
                                            }
                                            entity.Entry(pud).State = EntityState.Modified;
                                            entity.SaveChanges();

                                            //entity.PurchaseDetailInTransactions.Remove(p);
                                            //entity.SaveChanges();

                                            p.Qty = 0;
                                            entity.Entry(p).State = EntityState.Modified;

                                            entity.PurchaseDetailInTransactions.Remove(p);
                                            entity.SaveChanges();
                                        }
                                    }
                                }
                                #endregion






                                LoadData();
                                if (System.Windows.Forms.Application.OpenForms["TransactionList"] != null)
                                {
                                    TransactionList newForm = (TransactionList)System.Windows.Forms.Application.OpenForms["TransactionList"];
                                    newForm.LoadData();
                                }

                                if (System.Windows.Forms.Application.OpenForms["CreditTransactionList"] != null)
                                {
                                    CreditTransactionList newForm = (CreditTransactionList)System.Windows.Forms.Application.OpenForms["CreditTransactionList"];
                                    newForm.LoadData();
                                }
                            }
                        }
                    }
                }
            }    
        }
      

        #endregion

        #region Function
        private void Visible_Prepaid(bool v)
        {
            lblPrevTitle.Visible = v;
            label19.Visible = v;
            lblOutstandingAmount.Visible = v;
        }

        private void LoadData()
        {
            bool optionvisible = Utility.TransactionDelRefHide(shopid);
            dgvTransactionDetail.Columns[11].Visible = optionvisible;

            dgvTransactionDetail_CustomCellFormatting();
            dgvTransactionDetail.AutoGenerateColumns = false;
            //tlpCredit.Visible = false;
            Visible_Prepaid(false);
            Transaction transactionObject = (from t in entity.Transactions where t.Id == transactionId select t).FirstOrDefault();
            lblSalePerson.Text = (transactionObject.User == null) ? "-" : transactionObject.User.Name;
            lblDate.Text = transactionObject.DateTime.Value.ToString("dd-MM-yyyy");

            date = transactionObject.DateTime.Value;
            lblTime.Text = transactionObject.DateTime.Value.ToString("hh:mm");
            lblCustomerName.Text = (transactionObject.Customer == null) ? "-" : transactionObject.Customer.Name;
            txtNote.Text = transactionObject.Note;
           
            List<TransactionDetail> _tdList = new List<TransactionDetail>();

            if (transactionObject.Customer.Name == null)
            {
                cboCustomer.SelectedIndex = 0;
            }
            else
            {
                cboCustomer.Text = transactionObject.Customer.Name;
            }

            if (transactionObject.Type == TransactionType.Settlement)
            {
                dgvTransactionDetail.DataSource = "";
                //lRecieveAmunt.Text = transactionObject.RecieveAmount.ToString();
                lblDiscount.Text = "0";
                if (Convert.ToInt32(transactionObject.MCDiscountAmt)!= 0)
                {
                    lblMCDiscount.Text = Convert.ToInt32(transactionObject.MCDiscountAmt).ToString();
                }
                else if (Convert.ToInt32(transactionObject.BDDiscountAmt) != 0)
                {
                    lblMCDiscount.Text = Convert.ToInt32(transactionObject.BDDiscountAmt).ToString();
                }
             
                lblTotal.Text = transactionObject.TotalAmount.ToString();
                lblPaymentMethod1.Text = (transactionObject.PaymentType == null) ? "-" : transactionObject.PaymentType.Name;
                
                tlpCash.Visible = true;
            }
            else if (transactionObject.Type == TransactionType.Sale || transactionObject.Type == TransactionType.Credit)
            {
                //dgvTransactionDetail.DataSource = transactionObject.TransactionDetails.Where(x=>x.IsDeleted != true).ToList();
                dgvTransactionDetail.DataSource = transactionObject.TransactionDetails.Where(x => x.IsDeleted ==delete && x.ProductId!=null).ToList();
             // lblRecieveAmunt.Text = transactionObject.RecieveAmount.ToString();
                int discount = 0;
                int tax = 0;

                //List<TransactionDetail> _tdList = (from td in transactionObject.TransactionDetails where td.IsDeleted == false select td).ToList();
                 _tdList = (from td in transactionObject.TransactionDetails where td.IsDeleted == delete && td.ProductId != null select td).ToList();
                foreach (TransactionDetail td in _tdList)
                {
                    discount += Convert.ToInt32(((td.UnitPrice) * (td.DiscountRate / 100)) * td.Qty);
                    tax += Convert.ToInt32((td.UnitPrice * (td.TaxRate / 100)) * td.Qty);                   
                }
                lblDiscount.Text = (transactionObject.DiscountAmount ).ToString();
                lblTotalTax.Text = (transactionObject.TaxAmount).ToString();
                lblTotal.Text = transactionObject.TotalAmount.ToString();
                ExtraDiscount = Convert.ToInt32(transactionObject.DiscountAmount - discount);
                ExtraTax = Convert.ToInt32(transactionObject.TaxAmount - tax);
                if (Convert.ToInt32(transactionObject.MCDiscountAmt)!=0)
                {
                    lblMCDiscount.Text =Convert.ToInt32( transactionObject.MCDiscountAmt).ToString();
                }
                else if (Convert.ToInt32(transactionObject.BDDiscountAmt) != 0)
                {
                    lblMCDiscount.Text =Convert.ToInt32( transactionObject.BDDiscountAmt).ToString();
                }
                else
                {
                    lblMCDiscount.Text = "0";
                }
               

                
                lblPaymentMethod1.Text = (transactionObject.PaymentType == null) ? "-" : transactionObject.PaymentType.Name; ;
                if (transactionObject.PaymentTypeId == 2)
                {
                    List<Transaction> OldOutStandingList = entity.Transactions.Where(x => x.CustomerId == transactionObject.CustomerId).Where(x => x.IsPaid == false).Where(x => x.DateTime < transactionObject.DateTime).ToList().Where(x => x.IsDeleted != true).ToList();

                    long OldOutstandingAmount = 0;

                    foreach (Transaction t in OldOutStandingList)
                    {
                        OldOutstandingAmount += (long)t.TotalAmount - (long)t.RecieveAmount;
                    }
                    long PrepaidDebt = 0;
                  //List<Transaction> PrePaidList = entity.Transactions.Where(x => x.CustomerId == transactionObject.CustomerId).Where(x => x.IsActive == false).Where(x => x.Type == TransactionType.Prepaid).ToList().Where(x => x.IsDeleted != true).ToList();

                  //  foreach(Transaction t in PrePaidList)
                  //  {
                  //      long useAmount = 0;
                  //      if (t.UsePrePaidDebts != null)
                  //      {
                  //          useAmount = (long)t.UsePrePaidDebts.Sum(x => x.UseAmount);
                  //      }
                  //      //PrepaidDebt += Convert.ToInt32(t.RecieveAmount - useAmount);
                  //      PrepaidDebt += Convert.ToInt32(useAmount);
                  //  }
                    if (transactionObject.UsePrePaidDebts != null)
                    {
                        PrepaidDebt += (long)transactionObject.UsePrePaidDebts.Sum(x => x.UseAmount);
                    }
                    if (OldOutstandingAmount > 0)
                    {
                        OldOutstandingAmount -= PrepaidDebt;
                    }
                    //tlpCredit.Visible = true;
                    Visible_Prepaid(true);
                 
                    lblOutstandingAmount.Text = PrepaidDebt.ToString();

                
                    lblPrevTitle.Text = "Used Prepaid Amount   ";
                    //lblPayableCredit.Text = ((transactionObject.TotalAmount + OldOutstandingAmount) - transactionObject.RecieveAmount).ToString();
                    //lblOutstandingAmount.Text = OldOutstandingAmount.ToString();
                }
                //   //GiftCard
                else if (transactionObject.PaymentTypeId == 3)
                {
                    lblRecieveAmunt.Text = transactionObject.RecieveAmount.ToString();
                    lblAmountFromGiftCard.Visible = true;
                    lblAmountFromGiftcardTitle.Visible = true;
                    label20.Visible = true;
                    lblAmountFromGiftCard.Text = Convert.ToInt32(transactionObject.GiftCardAmount).ToString();
                }
                tlpCash.Visible = true;

            }

            //var totalQty= dgvTransactionDetail.Rows.Cast<DataGridViewRow>().Select(r=>Convert.ToInt32(r.Cells[3].Value)).Sum();
            //var totalUnitPrice= dgvTransactionDetail.Rows.Cast<DataGridViewRow>().Select(r=>Convert.ToInt32(r.Cells[4].Value)).Sum();
            //var totalDiscountRate = _tdList.Select(x => x.DiscountRate).Sum();
          // var list = _tdList.Where(x => Convert.ToInt32(x.DiscountRate) != 0).ToList();
            ////var totalQty = list.Select(x => x.Qty).Sum();
            ////var totalUnitPrice = list.Select(x => x.UnitPrice).Sum();
            ////var totalDiscountRate = list.Select(x => x.DiscountRate).Sum();
            //////foreach (TransactionDetail td in currentTransaction.TransactionDetails)
            //////{
            //////    discount += Convert.ToInt32(((td.UnitPrice) * (td.DiscountRate / 100)) * td.Qty);
            //////    //tax += Convert.ToInt32((td.UnitPrice * (td.TaxRate / 100)) * td.Qty);
            //////}

            ////int itemDiscountAmt = Convert.ToInt32(totalUnitPrice *totalQty)/100 * Convert.ToInt32(totalDiscountRate);

            int itemDiscountAmt = 0;
            foreach (TransactionDetail td in transactionObject.TransactionDetails)
            {
                itemDiscountAmt += Convert.ToInt32(((td.UnitPrice) * (td.DiscountRate / 100)) * td.Qty);
                
            }

            var _RefunDiscountAmt = entity.Transactions.Where(x => x.ParentId == transactionId && x.IsDeleted == false).Select(r=>r.DiscountAmount).Sum();
            var _RefunTotalAmt = entity.Transactions.Where(x => x.ParentId == transactionId && x.IsDeleted == false).Select(r => r.TotalAmount).Sum();
            var refund = dgvTransactionDetail.Rows.Cast<DataGridViewRow>().Select(r => Convert.ToInt32(r.Cells[8].Value)).Sum();

            
            if (refund != 0)
            {

                var TotalRefundAmt = _RefunTotalAmt - _RefunDiscountAmt;
                lblRefundAmt.Text = TotalRefundAmt.ToString();
            }
            else
            {
                lblRefundAmt.Text = "0";
            }

            //if (IsCash)
            //{
            //    lblTotal.Text = (transactionObject.TotalAmount - Convert.ToInt32(lblRefundAmt.Text)).ToString();
            //}
            //else
            //{
            //    lblTotal.Text = (transactionObject.RecieveAmount).ToString();
            //}

            lblRecieveAmunt.Text = transactionObject.RecieveAmount.ToString();
            
        }

     

        private void dgvTransactionDetail_CustomCellFormatting()
        {
            //Role Management
            RoleManagementController controller = new RoleManagementController();
            controller.Load(MemberShip.UserRoleId);
            // Transaction Delete
            if (!MemberShip.isAdmin && !controller.TransactionDetail.EditOrDelete)
            {
                dgvTransactionDetail.Columns["colDelete"].Visible = false;
            }

        }
        #endregion

        private void btnUpdate_Click(object sender, EventArgs e)
        {
            DialogResult result = MessageBox.Show("Are you sure you want to update?", "Update", MessageBoxButtons.OKCancel, MessageBoxIcon.Information);
            if (result.Equals(DialogResult.OK))
            {

                Transaction transactionObject = (from t in entity.Transactions where t.Id == transactionId select t).FirstOrDefault();
                transactionObject.CustomerId = Convert.ToInt32(cboCustomer.SelectedValue);
                transactionObject.UpdatedDate = DateTime.Now;
                entity.Entry(transactionObject).State = EntityState.Modified;
                entity.SaveChanges();
                MessageBox.Show("Successfully Updated!", "Update");
            }
        }

        private void lbAdvanceSearch_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            //CustomerSearch form = new CustomerSearch();
            //form.ShowDialog();
        }

        #region for saving Sale Qty in Stock Transaction table
        private void Save_SaleQty_ToStockTransaction(List<Stock_Transaction> productList, DateTime _tranDate)
        {
            int _year, _month;

            _year = _tranDate.Year;
            _month = _tranDate.Day;
            Utility.Sale_Run_Process(_year, _month, productList);
        }
        #endregion

        private void TransactionDetailForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (System.Windows.Forms.Application.OpenForms["TransactionList"] != null)
            {
                TransactionList newForm = (TransactionList)System.Windows.Forms.Application.OpenForms["TransactionList"];
                newForm.LoadData();
            }
        }

        private void label8_Click(object sender, EventArgs e)
        {

        }


    }
}
