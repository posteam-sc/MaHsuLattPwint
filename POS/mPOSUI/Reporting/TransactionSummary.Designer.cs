namespace POS
{
    partial class TransactionSummary
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TransactionSummary));
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.dtpTo = new System.Windows.Forms.DateTimePicker();
            this.label2 = new System.Windows.Forms.Label();
            this.dtpFrom = new System.Windows.Forms.DateTimePicker();
            this.label1 = new System.Windows.Forms.Label();
            this.gbTransactionList = new System.Windows.Forms.GroupBox();
            this.reportViewer1 = new Microsoft.Reporting.WinForms.ReportViewer();
            this.label3 = new System.Windows.Forms.Label();
            this.btnPrint = new System.Windows.Forms.Button();
            this.lblPeriod = new System.Windows.Forms.Label();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.cboshoplist = new System.Windows.Forms.ComboBox();
            this.label4 = new System.Windows.Forms.Label();
            this.groupBox2.SuspendLayout();
            this.gbTransactionList.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.dtpTo);
            this.groupBox2.Controls.Add(this.label2);
            this.groupBox2.Controls.Add(this.dtpFrom);
            this.groupBox2.Controls.Add(this.label1);
            this.groupBox2.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F);
            this.groupBox2.Location = new System.Drawing.Point(7, 4);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(421, 60);
            this.groupBox2.TabIndex = 0;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Time Period";
            // 
            // dtpTo
            // 
            this.dtpTo.CustomFormat = "dd-MMM-yyyy";
            this.dtpTo.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpTo.Location = new System.Drawing.Point(268, 21);
            this.dtpTo.Name = "dtpTo";
            this.dtpTo.Size = new System.Drawing.Size(133, 21);
            this.dtpTo.TabIndex = 3;
            this.dtpTo.ValueChanged += new System.EventHandler(this.dtpTo_ValueChanged);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(225, 25);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(21, 15);
            this.label2.TabIndex = 2;
            this.label2.Text = "To";
            // 
            // dtpFrom
            // 
            this.dtpFrom.CustomFormat = "dd-MMM-yyyy";
            this.dtpFrom.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpFrom.Location = new System.Drawing.Point(64, 22);
            this.dtpFrom.Name = "dtpFrom";
            this.dtpFrom.Size = new System.Drawing.Size(133, 21);
            this.dtpFrom.TabIndex = 1;
            this.dtpFrom.ValueChanged += new System.EventHandler(this.dtpFrom_ValueChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(6, 26);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(36, 15);
            this.label1.TabIndex = 0;
            this.label1.Text = "From";
            // 
            // gbTransactionList
            // 
            this.gbTransactionList.Controls.Add(this.reportViewer1);
            this.gbTransactionList.Controls.Add(this.label3);
            this.gbTransactionList.Controls.Add(this.btnPrint);
            this.gbTransactionList.Controls.Add(this.lblPeriod);
            this.gbTransactionList.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F);
            this.gbTransactionList.Location = new System.Drawing.Point(7, 70);
            this.gbTransactionList.Name = "gbTransactionList";
            this.gbTransactionList.Size = new System.Drawing.Size(735, 603);
            this.gbTransactionList.TabIndex = 2;
            this.gbTransactionList.TabStop = false;
            // 
            // reportViewer1
            // 
            this.reportViewer1.LocalReport.ReportEmbeddedResource = "POS.Reports.TransactionReport.rdlc";
            this.reportViewer1.Location = new System.Drawing.Point(6, 43);
            this.reportViewer1.Name = "reportViewer1";
            this.reportViewer1.ShowPrintButton = false;
            this.reportViewer1.ShowRefreshButton = false;
            this.reportViewer1.ShowStopButton = false;
            this.reportViewer1.ShowZoomControl = false;
            this.reportViewer1.Size = new System.Drawing.Size(722, 525);
            this.reportViewer1.TabIndex = 0;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(358, 16);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(43, 15);
            this.label3.TabIndex = 4;
            this.label3.Text = "Period";
            // 
            // btnPrint
            // 
            this.btnPrint.FlatAppearance.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(223)))), ((int)(((byte)(223)))), ((int)(((byte)(223)))));
            this.btnPrint.FlatAppearance.BorderSize = 0;
            this.btnPrint.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(223)))), ((int)(((byte)(223)))), ((int)(((byte)(223)))));
            this.btnPrint.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(223)))), ((int)(((byte)(223)))), ((int)(((byte)(223)))));
            this.btnPrint.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnPrint.Image = global::POS.Properties.Resources.print_big;
            this.btnPrint.Location = new System.Drawing.Point(551, 566);
            this.btnPrint.Name = "btnPrint";
            this.btnPrint.Size = new System.Drawing.Size(117, 37);
            this.btnPrint.TabIndex = 3;
            this.btnPrint.UseVisualStyleBackColor = true;
            this.btnPrint.Click += new System.EventHandler(this.btnPrint_Click);
            // 
            // lblPeriod
            // 
            this.lblPeriod.AutoSize = true;
            this.lblPeriod.Location = new System.Drawing.Point(408, 16);
            this.lblPeriod.Name = "lblPeriod";
            this.lblPeriod.Size = new System.Drawing.Size(11, 15);
            this.lblPeriod.TabIndex = 1;
            this.lblPeriod.Text = "-";
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.cboshoplist);
            this.groupBox1.Controls.Add(this.label4);
            this.groupBox1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F);
            this.groupBox1.Location = new System.Drawing.Point(434, 4);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(301, 60);
            this.groupBox1.TabIndex = 1;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "By shop";
            // 
            // cboshoplist
            // 
            this.cboshoplist.FormattingEnabled = true;
            this.cboshoplist.Location = new System.Drawing.Point(67, 20);
            this.cboshoplist.Name = "cboshoplist";
            this.cboshoplist.Size = new System.Drawing.Size(200, 23);
            this.cboshoplist.TabIndex = 1;
            this.cboshoplist.SelectedIndexChanged += new System.EventHandler(this.cboshoplist_selectedIndexChanged);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(16, 25);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(34, 15);
            this.label4.TabIndex = 0;
            this.label4.Text = "shop";
            // 
            // TransactionSummary
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.Control;
            this.ClientSize = new System.Drawing.Size(747, 676);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.gbTransactionList);
            this.Controls.Add(this.groupBox2);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "TransactionSummary";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Transaction Summary Report";
            this.Load += new System.EventHandler(this.TransactionSummary_Load);
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.gbTransactionList.ResumeLayout(false);
            this.gbTransactionList.PerformLayout();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.DateTimePicker dtpTo;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.DateTimePicker dtpFrom;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.GroupBox gbTransactionList;
        private Microsoft.Reporting.WinForms.ReportViewer reportViewer1;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Button btnPrint;
        private System.Windows.Forms.Label lblPeriod;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.ComboBox cboshoplist;
        private System.Windows.Forms.Label label4;
    }
}