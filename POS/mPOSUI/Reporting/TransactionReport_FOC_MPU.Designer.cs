namespace POS
{
    partial class TransactionReport_FOC_MPU
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TransactionReport_FOC_MPU));
            this.chkFOC = new System.Windows.Forms.CheckBox();
            this.chkCredit = new System.Windows.Forms.CheckBox();
            this.chkCash = new System.Windows.Forms.CheckBox();
            this.gbPaymentType = new System.Windows.Forms.GroupBox();
            this.chkTester = new System.Windows.Forms.CheckBox();
            this.chkGiftCard = new System.Windows.Forms.CheckBox();
            this.chkCounter = new System.Windows.Forms.CheckBox();
            this.chkCashier = new System.Windows.Forms.CheckBox();
            this.lblCounterName = new System.Windows.Forms.Label();
            this.lblCashierName = new System.Windows.Forms.Label();
            this.cboCounter = new System.Windows.Forms.ComboBox();
            this.cboCashier = new System.Windows.Forms.ComboBox();
            this.reportViewer1 = new Microsoft.Reporting.WinForms.ReportViewer();
            this.label3 = new System.Windows.Forms.Label();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.gbTransactionList = new System.Windows.Forms.GroupBox();
            this.lblPeriod = new System.Windows.Forms.Label();
            this.dtpTo = new System.Windows.Forms.DateTimePicker();
            this.label2 = new System.Windows.Forms.Label();
            this.dtpFrom = new System.Windows.Forms.DateTimePicker();
            this.label1 = new System.Windows.Forms.Label();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.rdbSummary = new System.Windows.Forms.RadioButton();
            this.rdbDebt = new System.Windows.Forms.RadioButton();
            this.rdbRefund = new System.Windows.Forms.RadioButton();
            this.rdbSale = new System.Windows.Forms.RadioButton();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.groupBox4 = new System.Windows.Forms.GroupBox();
            this.cboshoplist = new System.Windows.Forms.ComboBox();
            this.label4 = new System.Windows.Forms.Label();
            this.gbBank = new System.Windows.Forms.GroupBox();
            this.chkOnePay = new System.Windows.Forms.CheckBox();
            this.chkWavePay = new System.Windows.Forms.CheckBox();
            this.chkAYAPay = new System.Windows.Forms.CheckBox();
            this.chkCBPay = new System.Windows.Forms.CheckBox();
            this.chkKBZPay = new System.Windows.Forms.CheckBox();
            this.chkUnionPay = new System.Windows.Forms.CheckBox();
            this.chkMaster = new System.Windows.Forms.CheckBox();
            this.chkVisa = new System.Windows.Forms.CheckBox();
            this.chkJCB = new System.Windows.Forms.CheckBox();
            this.chkMPU = new System.Windows.Forms.CheckBox();
            this.chkSaiPay = new System.Windows.Forms.CheckBox();
            this.chkBankTransfer = new System.Windows.Forms.CheckBox();
            this.chkBank = new System.Windows.Forms.CheckBox();
            this.gbPaymentType.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.gbTransactionList.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.groupBox4.SuspendLayout();
            this.gbBank.SuspendLayout();
            this.SuspendLayout();
            // 
            // chkFOC
            // 
            this.chkFOC.AutoSize = true;
            this.chkFOC.Checked = true;
            this.chkFOC.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkFOC.Location = new System.Drawing.Point(247, 20);
            this.chkFOC.Name = "chkFOC";
            this.chkFOC.Size = new System.Drawing.Size(50, 19);
            this.chkFOC.TabIndex = 3;
            this.chkFOC.Text = "FOC";
            this.chkFOC.UseVisualStyleBackColor = true;
            this.chkFOC.CheckedChanged += new System.EventHandler(this.chkFOC_CheckedChanged);
            // 
            // chkCredit
            // 
            this.chkCredit.AutoSize = true;
            this.chkCredit.Checked = true;
            this.chkCredit.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkCredit.Location = new System.Drawing.Point(374, 20);
            this.chkCredit.Name = "chkCredit";
            this.chkCredit.Size = new System.Drawing.Size(58, 19);
            this.chkCredit.TabIndex = 4;
            this.chkCredit.Text = "Credit";
            this.chkCredit.UseVisualStyleBackColor = true;
            this.chkCredit.CheckedChanged += new System.EventHandler(this.chkCredit_CheckedChanged);
            // 
            // chkCash
            // 
            this.chkCash.AutoSize = true;
            this.chkCash.Checked = true;
            this.chkCash.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkCash.Location = new System.Drawing.Point(26, 20);
            this.chkCash.Name = "chkCash";
            this.chkCash.Size = new System.Drawing.Size(54, 19);
            this.chkCash.TabIndex = 0;
            this.chkCash.Text = "Cash";
            this.chkCash.UseVisualStyleBackColor = true;
            this.chkCash.CheckedChanged += new System.EventHandler(this.chkCash_CheckedChanged);
            // 
            // gbPaymentType
            // 
            this.gbPaymentType.Controls.Add(this.gbBank);
            this.gbPaymentType.Controls.Add(this.chkTester);
            this.gbPaymentType.Controls.Add(this.chkFOC);
            this.gbPaymentType.Controls.Add(this.chkCredit);
            this.gbPaymentType.Controls.Add(this.chkGiftCard);
            this.gbPaymentType.Controls.Add(this.chkCash);
            this.gbPaymentType.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F);
            this.gbPaymentType.Location = new System.Drawing.Point(10, 221);
            this.gbPaymentType.Name = "gbPaymentType";
            this.gbPaymentType.Size = new System.Drawing.Size(746, 123);
            this.gbPaymentType.TabIndex = 4;
            this.gbPaymentType.TabStop = false;
            this.gbPaymentType.Text = "Report Payment Type";
            // 
            // chkTester
            // 
            this.chkTester.AutoSize = true;
            this.chkTester.Checked = true;
            this.chkTester.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkTester.Location = new System.Drawing.Point(505, 20);
            this.chkTester.Name = "chkTester";
            this.chkTester.Size = new System.Drawing.Size(60, 19);
            this.chkTester.TabIndex = 5;
            this.chkTester.Text = "Tester";
            this.chkTester.UseVisualStyleBackColor = true;
            this.chkTester.CheckedChanged += new System.EventHandler(this.chkTester_CheckedChanged);
            // 
            // chkGiftCard
            // 
            this.chkGiftCard.AutoSize = true;
            this.chkGiftCard.Checked = true;
            this.chkGiftCard.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkGiftCard.Location = new System.Drawing.Point(122, 20);
            this.chkGiftCard.Name = "chkGiftCard";
            this.chkGiftCard.Size = new System.Drawing.Size(73, 19);
            this.chkGiftCard.TabIndex = 1;
            this.chkGiftCard.Text = "Gift Card";
            this.chkGiftCard.UseVisualStyleBackColor = true;
            this.chkGiftCard.CheckedChanged += new System.EventHandler(this.chkGiftCard_CheckedChanged);
            // 
            // chkCounter
            // 
            this.chkCounter.AutoSize = true;
            this.chkCounter.Location = new System.Drawing.Point(409, 16);
            this.chkCounter.Name = "chkCounter";
            this.chkCounter.Size = new System.Drawing.Size(82, 19);
            this.chkCounter.TabIndex = 3;
            this.chkCounter.Text = "ByCounter";
            this.chkCounter.UseVisualStyleBackColor = true;
            this.chkCounter.CheckedChanged += new System.EventHandler(this.chkCounter_CheckedChanged);
            // 
            // chkCashier
            // 
            this.chkCashier.AutoSize = true;
            this.chkCashier.Location = new System.Drawing.Point(97, 23);
            this.chkCashier.Name = "chkCashier";
            this.chkCashier.Size = new System.Drawing.Size(81, 19);
            this.chkCashier.TabIndex = 0;
            this.chkCashier.Text = "ByCashier";
            this.chkCashier.UseVisualStyleBackColor = true;
            this.chkCashier.CheckedChanged += new System.EventHandler(this.chkCashier_CheckedChanged);
            // 
            // lblCounterName
            // 
            this.lblCounterName.AutoSize = true;
            this.lblCounterName.Enabled = false;
            this.lblCounterName.Location = new System.Drawing.Point(406, 43);
            this.lblCounterName.Name = "lblCounterName";
            this.lblCounterName.Size = new System.Drawing.Size(87, 15);
            this.lblCounterName.TabIndex = 4;
            this.lblCounterName.Text = "Counter Name";
            // 
            // lblCashierName
            // 
            this.lblCashierName.AutoSize = true;
            this.lblCashierName.Enabled = false;
            this.lblCashierName.Location = new System.Drawing.Point(94, 48);
            this.lblCashierName.Name = "lblCashierName";
            this.lblCashierName.Size = new System.Drawing.Size(86, 15);
            this.lblCashierName.TabIndex = 1;
            this.lblCashierName.Text = "Cashier Name";
            // 
            // cboCounter
            // 
            this.cboCounter.Enabled = false;
            this.cboCounter.FormattingEnabled = true;
            this.cboCounter.Location = new System.Drawing.Point(409, 73);
            this.cboCounter.Name = "cboCounter";
            this.cboCounter.Size = new System.Drawing.Size(227, 23);
            this.cboCounter.TabIndex = 5;
            this.cboCounter.SelectedIndexChanged += new System.EventHandler(this.cboCounter_SelectedIndexChanged);
            // 
            // cboCashier
            // 
            this.cboCashier.Enabled = false;
            this.cboCashier.FormattingEnabled = true;
            this.cboCashier.Location = new System.Drawing.Point(98, 71);
            this.cboCashier.Name = "cboCashier";
            this.cboCashier.Size = new System.Drawing.Size(227, 23);
            this.cboCashier.TabIndex = 2;
            this.cboCashier.SelectedIndexChanged += new System.EventHandler(this.cboCashier_SelectedIndexChanged);
            // 
            // reportViewer1
            // 
            this.reportViewer1.LocalReport.ReportEmbeddedResource = "POS.Reports.TransactionReport.rdlc";
            this.reportViewer1.Location = new System.Drawing.Point(12, 30);
            this.reportViewer1.Name = "reportViewer1";
            this.reportViewer1.ShowPrintButton = false;
            this.reportViewer1.ShowRefreshButton = false;
            this.reportViewer1.ShowStopButton = false;
            this.reportViewer1.ShowZoomControl = false;
            this.reportViewer1.Size = new System.Drawing.Size(742, 357);
            this.reportViewer1.TabIndex = 0;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(358, 16);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(37, 13);
            this.label3.TabIndex = 4;
            this.label3.Text = "Period";
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.chkCounter);
            this.groupBox3.Controls.Add(this.chkCashier);
            this.groupBox3.Controls.Add(this.lblCounterName);
            this.groupBox3.Controls.Add(this.lblCashierName);
            this.groupBox3.Controls.Add(this.cboCounter);
            this.groupBox3.Controls.Add(this.cboCashier);
            this.groupBox3.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F);
            this.groupBox3.Location = new System.Drawing.Point(10, 1);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(695, 108);
            this.groupBox3.TabIndex = 0;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "By Cashier or Counter";
            // 
            // gbTransactionList
            // 
            this.gbTransactionList.Controls.Add(this.reportViewer1);
            this.gbTransactionList.Controls.Add(this.label3);
            this.gbTransactionList.Controls.Add(this.lblPeriod);
            this.gbTransactionList.Location = new System.Drawing.Point(2, 350);
            this.gbTransactionList.Name = "gbTransactionList";
            this.gbTransactionList.Size = new System.Drawing.Size(754, 395);
            this.gbTransactionList.TabIndex = 5;
            this.gbTransactionList.TabStop = false;
            // 
            // lblPeriod
            // 
            this.lblPeriod.AutoSize = true;
            this.lblPeriod.Location = new System.Drawing.Point(408, 16);
            this.lblPeriod.Name = "lblPeriod";
            this.lblPeriod.Size = new System.Drawing.Size(10, 13);
            this.lblPeriod.TabIndex = 1;
            this.lblPeriod.Text = "-";
            // 
            // dtpTo
            // 
            this.dtpTo.CustomFormat = "dd-MMM-yyyy";
            this.dtpTo.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpTo.Location = new System.Drawing.Point(277, 24);
            this.dtpTo.Name = "dtpTo";
            this.dtpTo.Size = new System.Drawing.Size(118, 21);
            this.dtpTo.TabIndex = 3;
            this.dtpTo.ValueChanged += new System.EventHandler(this.dtpTo_ValueChanged);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(218, 26);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(21, 15);
            this.label2.TabIndex = 2;
            this.label2.Text = "To";
            // 
            // dtpFrom
            // 
            this.dtpFrom.CustomFormat = "dd-MMM-yyyy";
            this.dtpFrom.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpFrom.Location = new System.Drawing.Point(68, 24);
            this.dtpFrom.Name = "dtpFrom";
            this.dtpFrom.Size = new System.Drawing.Size(118, 21);
            this.dtpFrom.TabIndex = 1;
            this.dtpFrom.ValueChanged += new System.EventHandler(this.dtpFrom_ValueChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(8, 26);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(36, 15);
            this.label1.TabIndex = 0;
            this.label1.Text = "From";
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.dtpTo);
            this.groupBox2.Controls.Add(this.label2);
            this.groupBox2.Controls.Add(this.dtpFrom);
            this.groupBox2.Controls.Add(this.label1);
            this.groupBox2.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F);
            this.groupBox2.Location = new System.Drawing.Point(10, 159);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(418, 66);
            this.groupBox2.TabIndex = 2;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Report Period";
            // 
            // rdbSummary
            // 
            this.rdbSummary.AutoSize = true;
            this.rdbSummary.Location = new System.Drawing.Point(58, 17);
            this.rdbSummary.Name = "rdbSummary";
            this.rdbSummary.Size = new System.Drawing.Size(78, 19);
            this.rdbSummary.TabIndex = 0;
            this.rdbSummary.Text = "Summary";
            this.rdbSummary.UseVisualStyleBackColor = true;
            this.rdbSummary.CheckedChanged += new System.EventHandler(this.rdbSummary_CheckedChanged);
            // 
            // rdbDebt
            // 
            this.rdbDebt.AutoSize = true;
            this.rdbDebt.Location = new System.Drawing.Point(588, 17);
            this.rdbDebt.Name = "rdbDebt";
            this.rdbDebt.Size = new System.Drawing.Size(87, 19);
            this.rdbDebt.TabIndex = 3;
            this.rdbDebt.Text = "Settlement ";
            this.rdbDebt.UseVisualStyleBackColor = true;
            this.rdbDebt.CheckedChanged += new System.EventHandler(this.rdbDebt_CheckedChanged);
            // 
            // rdbRefund
            // 
            this.rdbRefund.AutoSize = true;
            this.rdbRefund.Location = new System.Drawing.Point(411, 17);
            this.rdbRefund.Name = "rdbRefund";
            this.rdbRefund.Size = new System.Drawing.Size(65, 19);
            this.rdbRefund.TabIndex = 2;
            this.rdbRefund.Text = "Refund";
            this.rdbRefund.UseVisualStyleBackColor = true;
            this.rdbRefund.CheckedChanged += new System.EventHandler(this.rdbRefund_CheckedChanged);
            // 
            // rdbSale
            // 
            this.rdbSale.AutoSize = true;
            this.rdbSale.Checked = true;
            this.rdbSale.Location = new System.Drawing.Point(239, 17);
            this.rdbSale.Name = "rdbSale";
            this.rdbSale.Size = new System.Drawing.Size(50, 19);
            this.rdbSale.TabIndex = 1;
            this.rdbSale.TabStop = true;
            this.rdbSale.Text = "Sale";
            this.rdbSale.UseVisualStyleBackColor = true;
            this.rdbSale.CheckedChanged += new System.EventHandler(this.rdbSale_CheckedChanged);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.rdbSummary);
            this.groupBox1.Controls.Add(this.rdbDebt);
            this.groupBox1.Controls.Add(this.rdbRefund);
            this.groupBox1.Controls.Add(this.rdbSale);
            this.groupBox1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F);
            this.groupBox1.Location = new System.Drawing.Point(10, 110);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(746, 49);
            this.groupBox1.TabIndex = 1;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Report Catergory";
            // 
            // groupBox4
            // 
            this.groupBox4.Controls.Add(this.cboshoplist);
            this.groupBox4.Controls.Add(this.label4);
            this.groupBox4.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F);
            this.groupBox4.Location = new System.Drawing.Point(440, 165);
            this.groupBox4.Name = "groupBox4";
            this.groupBox4.Size = new System.Drawing.Size(316, 60);
            this.groupBox4.TabIndex = 3;
            this.groupBox4.TabStop = false;
            this.groupBox4.Text = "Report by shop";
            // 
            // cboshoplist
            // 
            this.cboshoplist.FormattingEnabled = true;
            this.cboshoplist.Location = new System.Drawing.Point(77, 22);
            this.cboshoplist.Name = "cboshoplist";
            this.cboshoplist.Size = new System.Drawing.Size(200, 23);
            this.cboshoplist.TabIndex = 1;
            this.cboshoplist.SelectedIndexChanged += new System.EventHandler(this.cboshoplist_selectedIndexChanged);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(13, 25);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(36, 15);
            this.label4.TabIndex = 0;
            this.label4.Text = "Shop";
            // 
            // gbBank
            // 
            this.gbBank.Controls.Add(this.chkOnePay);
            this.gbBank.Controls.Add(this.chkWavePay);
            this.gbBank.Controls.Add(this.chkAYAPay);
            this.gbBank.Controls.Add(this.chkCBPay);
            this.gbBank.Controls.Add(this.chkKBZPay);
            this.gbBank.Controls.Add(this.chkUnionPay);
            this.gbBank.Controls.Add(this.chkMaster);
            this.gbBank.Controls.Add(this.chkVisa);
            this.gbBank.Controls.Add(this.chkJCB);
            this.gbBank.Controls.Add(this.chkMPU);
            this.gbBank.Controls.Add(this.chkSaiPay);
            this.gbBank.Controls.Add(this.chkBankTransfer);
            this.gbBank.Controls.Add(this.chkBank);
            this.gbBank.Location = new System.Drawing.Point(19, 41);
            this.gbBank.Name = "gbBank";
            this.gbBank.Size = new System.Drawing.Size(595, 71);
            this.gbBank.TabIndex = 7;
            this.gbBank.TabStop = false;
            // 
            // chkOnePay
            // 
            this.chkOnePay.AutoSize = true;
            this.chkOnePay.Checked = true;
            this.chkOnePay.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkOnePay.Location = new System.Drawing.Point(228, 47);
            this.chkOnePay.Name = "chkOnePay";
            this.chkOnePay.Size = new System.Drawing.Size(72, 19);
            this.chkOnePay.TabIndex = 2;
            this.chkOnePay.Text = "One Pay";
            this.chkOnePay.UseVisualStyleBackColor = true;
            this.chkOnePay.CheckedChanged += new System.EventHandler(this.chkOnePay_CheckedChanged);
            // 
            // chkWavePay
            // 
            this.chkWavePay.AutoSize = true;
            this.chkWavePay.Checked = true;
            this.chkWavePay.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkWavePay.Location = new System.Drawing.Point(121, 47);
            this.chkWavePay.Name = "chkWavePay";
            this.chkWavePay.Size = new System.Drawing.Size(79, 19);
            this.chkWavePay.TabIndex = 2;
            this.chkWavePay.Text = "Wave Pay";
            this.chkWavePay.UseVisualStyleBackColor = true;
            this.chkWavePay.CheckedChanged += new System.EventHandler(this.chkWavePay_CheckedChanged);
            // 
            // chkAYAPay
            // 
            this.chkAYAPay.AutoSize = true;
            this.chkAYAPay.Checked = true;
            this.chkAYAPay.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkAYAPay.Location = new System.Drawing.Point(6, 47);
            this.chkAYAPay.Name = "chkAYAPay";
            this.chkAYAPay.Size = new System.Drawing.Size(70, 19);
            this.chkAYAPay.TabIndex = 2;
            this.chkAYAPay.Text = "AYA Pay";
            this.chkAYAPay.UseVisualStyleBackColor = true;
            this.chkAYAPay.CheckedChanged += new System.EventHandler(this.chkAYAPay_CheckedChanged);
            // 
            // chkCBPay
            // 
            this.chkCBPay.AutoSize = true;
            this.chkCBPay.Checked = true;
            this.chkCBPay.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkCBPay.Location = new System.Drawing.Point(508, 46);
            this.chkCBPay.Name = "chkCBPay";
            this.chkCBPay.Size = new System.Drawing.Size(65, 19);
            this.chkCBPay.TabIndex = 2;
            this.chkCBPay.Text = "CB Pay";
            this.chkCBPay.UseVisualStyleBackColor = true;
            this.chkCBPay.CheckedChanged += new System.EventHandler(this.chkCBPay_CheckedChanged);
            // 
            // chkKBZPay
            // 
            this.chkKBZPay.AutoSize = true;
            this.chkKBZPay.Checked = true;
            this.chkKBZPay.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkKBZPay.Location = new System.Drawing.Point(419, 46);
            this.chkKBZPay.Name = "chkKBZPay";
            this.chkKBZPay.Size = new System.Drawing.Size(72, 19);
            this.chkKBZPay.TabIndex = 2;
            this.chkKBZPay.Text = "KBZ Pay";
            this.chkKBZPay.UseVisualStyleBackColor = true;
            this.chkKBZPay.CheckedChanged += new System.EventHandler(this.chkKBZPay_CheckedChanged);
            // 
            // chkUnionPay
            // 
            this.chkUnionPay.AutoSize = true;
            this.chkUnionPay.Checked = true;
            this.chkUnionPay.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkUnionPay.Location = new System.Drawing.Point(508, 24);
            this.chkUnionPay.Name = "chkUnionPay";
            this.chkUnionPay.Size = new System.Drawing.Size(82, 19);
            this.chkUnionPay.TabIndex = 2;
            this.chkUnionPay.Text = "Union Pay";
            this.chkUnionPay.UseVisualStyleBackColor = true;
            this.chkUnionPay.CheckedChanged += new System.EventHandler(this.chkUnionPay_CheckedChanged);
            // 
            // chkMaster
            // 
            this.chkMaster.AutoSize = true;
            this.chkMaster.Checked = true;
            this.chkMaster.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkMaster.Location = new System.Drawing.Point(419, 24);
            this.chkMaster.Name = "chkMaster";
            this.chkMaster.Size = new System.Drawing.Size(64, 19);
            this.chkMaster.TabIndex = 2;
            this.chkMaster.Text = "Master";
            this.chkMaster.UseVisualStyleBackColor = true;
            this.chkMaster.CheckedChanged += new System.EventHandler(this.chkMaster_CheckedChanged);
            // 
            // chkVisa
            // 
            this.chkVisa.AutoSize = true;
            this.chkVisa.Checked = true;
            this.chkVisa.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkVisa.Location = new System.Drawing.Point(327, 24);
            this.chkVisa.Name = "chkVisa";
            this.chkVisa.Size = new System.Drawing.Size(49, 19);
            this.chkVisa.TabIndex = 2;
            this.chkVisa.Text = "Visa";
            this.chkVisa.UseVisualStyleBackColor = true;
            this.chkVisa.CheckedChanged += new System.EventHandler(this.chkVisa_CheckedChanged);
            // 
            // chkJCB
            // 
            this.chkJCB.AutoSize = true;
            this.chkJCB.Checked = true;
            this.chkJCB.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkJCB.Location = new System.Drawing.Point(228, 24);
            this.chkJCB.Name = "chkJCB";
            this.chkJCB.Size = new System.Drawing.Size(48, 19);
            this.chkJCB.TabIndex = 2;
            this.chkJCB.Text = "JCB";
            this.chkJCB.UseVisualStyleBackColor = true;
            this.chkJCB.CheckedChanged += new System.EventHandler(this.chkJCB_CheckedChanged);
            // 
            // chkMPU
            // 
            this.chkMPU.AutoSize = true;
            this.chkMPU.Checked = true;
            this.chkMPU.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkMPU.Location = new System.Drawing.Point(121, 24);
            this.chkMPU.Name = "chkMPU";
            this.chkMPU.Size = new System.Drawing.Size(54, 19);
            this.chkMPU.TabIndex = 2;
            this.chkMPU.Text = "MPU";
            this.chkMPU.UseVisualStyleBackColor = true;
            this.chkMPU.CheckedChanged += new System.EventHandler(this.chkMPU_CheckedChanged);
            // 
            // chkSaiPay
            // 
            this.chkSaiPay.AutoSize = true;
            this.chkSaiPay.Checked = true;
            this.chkSaiPay.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkSaiPay.Location = new System.Drawing.Point(327, 46);
            this.chkSaiPay.Name = "chkSaiPay";
            this.chkSaiPay.Size = new System.Drawing.Size(88, 19);
            this.chkSaiPay.TabIndex = 2;
            this.chkSaiPay.Text = "Sai Sai Pay";
            this.chkSaiPay.UseVisualStyleBackColor = true;
            this.chkSaiPay.CheckedChanged += new System.EventHandler(this.chkSaiPay_CheckedChanged);
            // 
            // chkBankTransfer
            // 
            this.chkBankTransfer.AutoSize = true;
            this.chkBankTransfer.Checked = true;
            this.chkBankTransfer.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkBankTransfer.Location = new System.Drawing.Point(6, 24);
            this.chkBankTransfer.Name = "chkBankTransfer";
            this.chkBankTransfer.Size = new System.Drawing.Size(102, 19);
            this.chkBankTransfer.TabIndex = 2;
            this.chkBankTransfer.Text = "Bank Transfer";
            this.chkBankTransfer.UseVisualStyleBackColor = true;
            this.chkBankTransfer.CheckedChanged += new System.EventHandler(this.chkBankTransfer_CheckedChanged);
            // 
            // chkBank
            // 
            this.chkBank.AutoSize = true;
            this.chkBank.Checked = true;
            this.chkBank.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkBank.Location = new System.Drawing.Point(6, 0);
            this.chkBank.Name = "chkBank";
            this.chkBank.Size = new System.Drawing.Size(54, 19);
            this.chkBank.TabIndex = 2;
            this.chkBank.Text = "Bank";
            this.chkBank.UseVisualStyleBackColor = true;
            this.chkBank.CheckedChanged += new System.EventHandler(this.chkBank_CheckedChanged);
            // 
            // TransactionReport_FOC_MPU
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.Control;
            this.ClientSize = new System.Drawing.Size(768, 749);
            this.Controls.Add(this.groupBox4);
            this.Controls.Add(this.gbPaymentType);
            this.Controls.Add(this.groupBox3);
            this.Controls.Add(this.gbTransactionList);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "TransactionReport_FOC_MPU";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Transaction Report";
            this.Load += new System.EventHandler(this.TransactionReport_FOC_MPU_Load);
            this.gbPaymentType.ResumeLayout(false);
            this.gbPaymentType.PerformLayout();
            this.groupBox3.ResumeLayout(false);
            this.groupBox3.PerformLayout();
            this.gbTransactionList.ResumeLayout(false);
            this.gbTransactionList.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.groupBox4.ResumeLayout(false);
            this.groupBox4.PerformLayout();
            this.gbBank.ResumeLayout(false);
            this.gbBank.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.CheckBox chkFOC;
        private System.Windows.Forms.CheckBox chkCredit;
        private System.Windows.Forms.CheckBox chkCash;
        private System.Windows.Forms.GroupBox gbPaymentType;
        private System.Windows.Forms.CheckBox chkGiftCard;
        private System.Windows.Forms.CheckBox chkCounter;
        private System.Windows.Forms.CheckBox chkCashier;
        private System.Windows.Forms.Label lblCounterName;
        private System.Windows.Forms.Label lblCashierName;
        private System.Windows.Forms.ComboBox cboCounter;
        private System.Windows.Forms.ComboBox cboCashier;
        private Microsoft.Reporting.WinForms.ReportViewer reportViewer1;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.GroupBox gbTransactionList;
        private System.Windows.Forms.Label lblPeriod;
        private System.Windows.Forms.DateTimePicker dtpTo;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.DateTimePicker dtpFrom;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.RadioButton rdbSummary;
        private System.Windows.Forms.RadioButton rdbDebt;
        private System.Windows.Forms.RadioButton rdbRefund;
        private System.Windows.Forms.RadioButton rdbSale;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.CheckBox chkTester;
        private System.Windows.Forms.GroupBox groupBox4;
        private System.Windows.Forms.ComboBox cboshoplist;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.GroupBox gbBank;
        private System.Windows.Forms.CheckBox chkOnePay;
        private System.Windows.Forms.CheckBox chkWavePay;
        private System.Windows.Forms.CheckBox chkAYAPay;
        private System.Windows.Forms.CheckBox chkCBPay;
        private System.Windows.Forms.CheckBox chkKBZPay;
        private System.Windows.Forms.CheckBox chkUnionPay;
        private System.Windows.Forms.CheckBox chkMaster;
        private System.Windows.Forms.CheckBox chkVisa;
        private System.Windows.Forms.CheckBox chkJCB;
        private System.Windows.Forms.CheckBox chkMPU;
        private System.Windows.Forms.CheckBox chkSaiPay;
        private System.Windows.Forms.CheckBox chkBankTransfer;
        private System.Windows.Forms.CheckBox chkBank;
    }
}