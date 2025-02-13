USE [mPOS]
GO
/****** Object:  UserDefinedFunction [dbo].[GetGWPGiftSetInvoiceAmount]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetGWPGiftSetInvoiceAmount]
(
	@GiftSystemId int,
	@CustomerTypeId int,
	@fromDate datetime,
	@toDate datetime,
	@CounterId int
)
RETURNS bigint
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Amount bigint

	Select @Amount = SUM(T.TotalAmount)
	From [Transaction] as T 
	inner join [GiftSystemInTransaction] as AG on T.Id = AG.TransactionId
	inner join Customer as C on T.CustomerId = C.Id
	Where AG.GiftSystemId = @GiftSystemId and 
	--C.CustomerTypeId = @CustomerTypeId and
	 CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsDeleted = 0
	and ((@CounterId=0 and 1=1) or (@CounterId!=0 and t.CounterId=@CounterId))
	--and ((@CustomerTypeId=1 and t.DateTime >= C.PromoteDate )   or (@CustomerTypeId=2 and t.DateTime  < C.PromoteDate))

	if (@Amount is null)
	Begin
		Set @Amount = 0
	End
	RETURN @Amount

END



GO
/****** Object:  UserDefinedFunction [dbo].[GetGWPGiftSetQty]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetGWPGiftSetQty]
(
	@GiftSystemId int,
	@CustomerTypeId int,
	@fromDate datetime,
	@toDate datetime,
	@CounterId int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @GiftSetQty int	
	SELECT @GiftSetQty = COUNT(*)
	FROM GiftSystemInTransaction as AG 
	inner join [Transaction] as T on T.Id = AG.TransactionId
	inner join Customer as C on C.Id = T.CustomerId
	WHERE GiftSystemId = @GiftSystemId and 
	--C.CustomerTypeId = @CustomerTypeId 
	CAST(T.DateTime as date) >= CAST(@fromDate as date) 
	and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsDeleted = 0 and ((@CounterId=0 and 1=1) or (@CounterId!=0 and t.CounterId=@CounterId))
	and ((@CustomerTypeId=1 and t.DateTime >= C.PromoteDate )   or (@CustomerTypeId=2 and t.DateTime  < C.PromoteDate))
	RETURN @GiftSetQty
END



GO
/****** Object:  UserDefinedFunction [dbo].[GetGWPName]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetGWPName]
(
	@productId int,
	@transactionId varchar(50)
	
)
RETURNS varchar(200)
AS
BEGIN
	Declare @GiftName varchar(200)
	DECLARE @AttachGId TABLE (Id int)

	insert into @AttachGId select A.GiftSystemId from GiftSystemInTransaction as A where A.TransactionId = @transactionId

	Declare @Gift TABLE (Name varchar(200), productId int)
	insert into @Gift select Product.Name, G.GiftProductId from GiftSystem as G inner join @AttachGId as a on G.Id = a.Id inner join Product on Product.Id=G.GiftProductId
	
	select @GiftName = Name
	from @Gift
	where productId = @productId
	
	RETURN @GiftName
END



GO
/****** Object:  Table [dbo].[Adjustment]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Adjustment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ResponsibleName] [nvarchar](20) NULL,
	[Reason] [nvarchar](200) NULL,
	[IsDeleted] [bit] NULL,
	[DeletedUserId] [int] NULL,
	[DeletedDate] [datetime] NULL,
	[UserId] [int] NULL,
	[AdjustmentDateTime] [datetime] NULL,
	[ProductId] [bigint] NULL,
	[AdjustmentQty] [int] NULL,
	[AdjustmentTypeId] [int] NOT NULL,
	[AdjustmentNo] [varchar](1000) NULL,
	[Count] [int] NULL,
	[IsApproved] [bit] NULL,
 CONSTRAINT [PK_Adjustment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AdjustmentType]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AdjustmentType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL,
 CONSTRAINT [PK_AdjustmentType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Authorize]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Authorize](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[licenseKey] [varchar](max) NULL,
	[macAddress] [varchar](max) NULL,
 CONSTRAINT [PK_Authorize] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Brand]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Brand](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL,
	[AutoGenerateNo] [int] NULL,
	[IsDelete] [bit] NULL,
 CONSTRAINT [PK_Brand] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[City]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[City](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CityName] [varchar](100) NULL,
	[IsDelete] [bit] NULL,
 CONSTRAINT [PK_City] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ConsignmentCounter]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConsignmentCounter](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL,
	[CounterLocation] [nvarchar](200) NULL,
	[PhoneNo] [nvarchar](max) NULL,
	[Email] [nvarchar](50) NULL,
	[Address] [nvarchar](max) NULL,
	[IsDelete] [bit] NULL,
 CONSTRAINT [PK_ConsignmentCounter] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ConsignmentSettlement]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConsignmentSettlement](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SettlementDate] [datetime] NOT NULL,
	[ConsignorId] [int] NOT NULL,
	[TotalSettlementPrice] [decimal](18, 0) NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[IsDelete] [bit] NOT NULL,
	[ConsignmentNo] [varchar](1000) NOT NULL,
	[FromTransactionDate] [datetime] NOT NULL,
	[ToTransactionDate] [datetime] NOT NULL,
	[Comment] [nvarchar](500) NULL,
	[count] [int] NULL,
 CONSTRAINT [PK_ConsignmentSettlement_TransactionDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ConsignmentSettlementDetail]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConsignmentSettlementDetail](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[ConsignmentNo] [varchar](1000) NOT NULL,
	[TransactionDetailId] [bigint] NOT NULL,
 CONSTRAINT [PK_ConsignmentSettlementDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Counter]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Counter](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[IsDelete] [bit] NULL,
 CONSTRAINT [PK_Counter] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Currency]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Currency](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Country] [nvarchar](50) NULL,
	[Symbol] [varchar](5) NULL,
	[CurrencyCode] [varchar](20) NULL,
	[LatestExchangeRate] [int] NULL,
 CONSTRAINT [PK_Currency] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Customer]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Customer](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](5) NULL,
	[Name] [nvarchar](200) NULL,
	[PhoneNumber] [varchar](50) NULL,
	[Address] [nvarchar](200) NULL,
	[NRC] [varchar](20) NULL,
	[Email] [varchar](100) NULL,
	[CityId] [int] NULL,
	[TownShip] [varchar](200) NULL,
	[Gender] [varchar](10) NULL,
	[Birthday] [date] NULL,
	[MemberTypeID] [int] NULL,
	[VIPMemberId] [varchar](200) NULL,
	[StartDate] [date] NULL,
	[CustomerCode] [varchar](50) NULL,
	[CustomerTypeId] [int] NULL,
	[PromoteDate] [datetime] NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomerType]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomerType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TypeName] [varchar](200) NOT NULL,
 CONSTRAINT [PK_CustomerType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DailyRecord]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DailyRecord](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[CounterId] [int] NULL,
	[StartDateTime] [datetime] NULL,
	[EndDateTime] [datetime] NULL,
	[OpeningBalance] [bigint] NULL,
	[ClosingBalance] [bigint] NULL,
	[AccuralAmount] [bigint] NULL,
	[DifferenceAmount] [bigint] NULL,
	[Comment] [nvarchar](max) NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_DailyRecord] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DeleteLog]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DeleteLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NULL,
	[CounterId] [int] NULL,
	[TransactionId] [varchar](20) NULL,
	[TransactionDetailId] [bigint] NULL,
	[IsParent] [bit] NULL,
	[DeletedDate] [datetime] NULL,
 CONSTRAINT [PK_DeleteLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ExchangeRateForTransaction]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExchangeRateForTransaction](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CurrencyId] [int] NOT NULL,
	[TransactionId] [varchar](20) NOT NULL,
	[ExchangeRate] [int] NOT NULL,
 CONSTRAINT [PK_ExchangeRateForTransaction] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Expense]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Expense](
	[Id] [varchar](50) NOT NULL,
	[ExpenseDate] [datetime] NULL,
	[IsApproved] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedUser] [int] NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedUser] [int] NULL,
	[TotalExpenseAmount] [decimal](18, 2) NULL,
	[Comment] [nvarchar](max) NULL,
	[ExpenseCategoryId] [int] NULL,
	[Count] [int] NULL,
 CONSTRAINT [PK_Expense] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ExpenseCategory]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExpenseCategory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[IsDelete] [bit] NULL,
 CONSTRAINT [PK_ExpenseCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ExpenseDetail]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExpenseDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ExpenseId] [varchar](50) NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
	[Qty] [decimal](18, 2) NOT NULL,
	[Price] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_ExpenseDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GiftCard]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GiftCard](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CardNumber] [varchar](200) NULL,
	[Amount] [bigint] NULL,
	[IsDelete] [bit] NULL,
	[IsUsed] [bit] NOT NULL,
	[ExpireDate] [datetime] NULL,
	[CustomerId] [int] NULL,
	[IsUsedDate] [datetime] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_GiftCard] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GiftCardInTransaction]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GiftCardInTransaction](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[GiftCardId] [int] NOT NULL,
	[TransactionId] [varchar](20) NOT NULL,
 CONSTRAINT [PK_GiftCardInCustomer] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GiftSystem]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GiftSystem](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [varchar](50) NOT NULL,
	[Name] [varchar](200) NULL,
	[MustBuyCostFrom] [bigint] NULL,
	[MustBuyCostTo] [bigint] NULL,
	[MustIncludeProductId] [bigint] NULL,
	[FilterBrandId] [int] NULL,
	[FilterCategoryId] [int] NULL,
	[FilterSubCategoryId] [int] NULL,
	[ValidFrom] [datetime] NOT NULL,
	[ValidTo] [datetime] NOT NULL,
	[UsePromotionQty] [bit] NOT NULL,
	[PromotionQty] [int] NULL,
	[GiftProductId] [bigint] NULL,
	[PriceForGiftProduct] [bigint] NOT NULL,
	[GiftCashAmount] [bigint] NULL,
	[DiscountPercentForTransaction] [int] NULL,
	[UseBrandFilter] [bit] NULL,
	[UseCategoryFilter] [bit] NULL,
	[UseSubCategoryFilter] [bit] NULL,
	[UseProductFilter] [bit] NULL,
	[IsActive] [bit] NULL,
	[UseSizeFilter] [bit] NULL,
	[UseQtyFilter] [bit] NULL,
	[FilterSize] [int] NULL,
	[FilterQty] [int] NULL,
 CONSTRAINT [PK_GiftSystem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GiftSystemInTransaction]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GiftSystemInTransaction](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[GiftSystemId] [int] NOT NULL,
	[TransactionId] [varchar](20) NOT NULL,
 CONSTRAINT [PK_GiftSystemInTransaction] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MainPurchase]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MainPurchase](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SupplierId] [int] NULL,
	[Date] [datetime] NULL,
	[VoucherNo] [nvarchar](50) NULL,
	[TotalAmount] [bigint] NULL,
	[Cash] [bigint] NULL,
	[OldCreditAmount] [bigint] NULL,
	[SettlementAmount] [bigint] NULL,
	[IsActive] [bit] NULL,
	[DiscountAmount] [int] NULL,
	[IsDeleted] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [int] NULL,
	[IsCompletedInvoice] [bit] NULL,
	[IsCompletedPaid] [bit] NULL,
	[IsPurchase] [bit] NULL,
 CONSTRAINT [PK_MainPurchase] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MemberCardRule]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MemberCardRule](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MemberTypeId] [int] NOT NULL,
	[RangeFrom] [varchar](200) NULL,
	[RangeTo] [varchar](200) NULL,
	[MCDiscount] [decimal](18, 0) NULL,
	[BDDiscount] [decimal](18, 0) NULL,
 CONSTRAINT [PK_MemberCardRule] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MemberType]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MemberType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL,
	[IsDelete] [bit] NULL,
 CONSTRAINT [PK_MemberType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NoveltySystem]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NoveltySystem](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[BrandId] [int] NULL,
	[ValidFrom] [datetime] NULL,
	[ValidTo] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
 CONSTRAINT [PK_NoveltySystem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PaymentType]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
 CONSTRAINT [PK_PaymentType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[pjForms]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[pjForms](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[TextEng] [varchar](50) NOT NULL,
	[TextMyanmar] [nvarchar](max) NULL,
	[AllowToLoad] [bit] NULL,
 CONSTRAINT [PK_Forms] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[pjForms_Localization]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[pjForms_Localization](
	[Id] [int] NOT NULL,
	[FormId] [int] NOT NULL,
	[ControlName] [nvarchar](max) NOT NULL,
	[Type] [varchar](20) NOT NULL,
	[Eng] [nvarchar](max) NOT NULL,
	[ZawGyi] [nvarchar](max) NULL,
	[MM3] [nvarchar](max) NULL,
	[Other1] [nvarchar](max) NULL,
	[Other2] [nvarchar](max) NULL,
	[AllowToLoad] [bit] NOT NULL,
 CONSTRAINT [PK_Forms_Localization] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Product]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Product](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL,
	[ProductCode] [varchar](50) NOT NULL,
	[Barcode] [varchar](50) NOT NULL,
	[Price] [bigint] NOT NULL,
	[Qty] [int] NULL,
	[BrandId] [int] NULL,
	[ProductLocation] [nvarchar](200) NULL,
	[ProductCategoryId] [int] NULL,
	[ProductSubCategoryId] [int] NULL,
	[UnitId] [int] NULL,
	[TaxId] [int] NULL,
	[MinStockQty] [int] NULL,
	[DiscountRate] [decimal](5, 2) NOT NULL,
	[IsWrapper] [bit] NULL,
	[IsConsignment] [bit] NULL,
	[IsDiscontinue] [bit] NULL,
	[ConsignmentPrice] [bigint] NULL,
	[ConsignmentCounterId] [int] NULL,
	[Size] [nvarchar](50) NULL,
	[PurchasePrice] [bigint] NULL,
	[IsNotifyMinStock] [bit] NULL,
	[Amount] [bigint] NULL,
	[Percent] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedBy] [int] NULL,
	[UpdatedDate] [datetime] NULL,
	[PhotoPath] [nvarchar](500) NULL,
	[WholeSalePrice] [bigint] NULL,
	[UnitType] [nvarchar](100) NULL,
 CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ProductCategory]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductCategory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[IsDelete] [bit] NULL,
 CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProductInNovelty]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductInNovelty](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[NoveltySystemId] [bigint] NULL,
	[ProductId] [bigint] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_ProductInNovelty] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProductPriceChange]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductPriceChange](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Price] [bigint] NULL,
	[UpdateDate] [datetime] NULL,
	[UserID] [int] NULL,
	[ProductId] [bigint] NULL,
	[OldPrice] [bigint] NULL,
 CONSTRAINT [PK_ProductPriceChange] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProductQuantityChange]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductQuantityChange](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductId] [bigint] NULL,
	[StockInQty] [bigint] NULL,
	[UpdateDate] [datetime] NULL,
	[UserID] [int] NULL,
 CONSTRAINT [PK_ProductQuantityChange] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProductSubCategory]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProductSubCategory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL,
	[ProductCategoryId] [int] NULL,
	[Prefix] [varchar](20) NULL,
	[IsDelete] [bit] NULL,
 CONSTRAINT [PK_ProductType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PurchaseDeleteLog]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PurchaseDeleteLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NULL,
	[CounterId] [int] NULL,
	[MainPurchaseId] [int] NULL,
	[PurchaseDetailId] [int] NULL,
	[IsParent] [bit] NULL,
	[DeletedDate] [datetime] NULL,
	[VoucherNo] [nvarchar](50) NULL,
 CONSTRAINT [PK_PurchaseDeleteLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PurchaseDetail]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PurchaseDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MainPurchaseId] [int] NULL,
	[ProductId] [bigint] NULL,
	[Qty] [int] NULL,
	[UnitPrice] [int] NULL,
	[CurrentQy] [int] NULL,
	[IsDeleted] [bit] NULL,
	[DeletedDate] [datetime] NULL,
	[DeletedUser] [int] NULL,
	[Date] [datetime] NULL,
	[ConvertQty] [numeric](18, 2) NULL,
	[expiredDate] [datetime] NULL,
 CONSTRAINT [PK_PurchaseDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PurchaseDetailInTransaction]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PurchaseDetailInTransaction](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [bigint] NULL,
	[TransactionDetailId] [bigint] NULL,
	[PurchaseDetailId] [int] NULL,
	[Qty] [int] NULL,
	[Date] [datetime] NULL,
	[IsSpecialChild] [bit] NULL,
 CONSTRAINT [PK_PurchaseDetailInTransaction] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RestaurantTable]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RestaurantTable](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Number] [nvarchar](20) NOT NULL,
	[Status] [bit] NOT NULL,
	[ExtraText] [varchar](50) NULL,
 CONSTRAINT [PK_RestaurantTable] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RoleManagement]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RoleManagement](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RuleFeature] [varchar](100) NOT NULL,
	[UserRoleId] [int] NOT NULL,
	[IsAllowed] [bit] NOT NULL,
 CONSTRAINT [PK_RoleManagement] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Setting]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Setting](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Key] [varchar](max) NULL,
	[Value] [nvarchar](max) NULL,
 CONSTRAINT [PK_Setting] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Shop]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[Shop](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ShopName] [varchar](max) NOT NULL,
	[Address] [varchar](max) NULL,
	[PhoneNumber] [varchar](200) NULL,
	[OpeningHours] [varchar](200) NULL,
	[CityId] [int] NOT NULL,
	[ShortCode] [varchar](2) NOT NULL,
	[IsDefaultShop] [bit] NULL,
 CONSTRAINT [PK_Shop] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SPDetail]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SPDetail](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[TransactionDetailID] [bigint] NULL,
	[ParentProductID] [bigint] NULL,
	[ChildProductID] [bigint] NULL,
	[Price] [bigint] NULL,
	[DiscountRate] [decimal](5, 2) NULL,
	[SPDetailID] [varchar](50) NULL,
	[ChildQty] [int] NULL,
 CONSTRAINT [PK_SPDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[StockInDetail]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StockInDetail](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[StockInHeaderId] [bigint] NULL,
	[ProductId] [bigint] NULL,
	[Qty] [int] NULL,
	[experiedDate] [date] NULL,
 CONSTRAINT [PK_StockInDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[StockInHeader]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[StockInHeader](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[StockCode] [varchar](50) NOT NULL,
	[Date] [datetime] NULL,
	[FromShopId] [int] NULL,
	[ToShopId] [int] NULL,
	[IsApproved] [bit] NULL,
	[IsDelete] [bit] NULL,
	[CreatedUser] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedUser] [int] NULL,
	[UpdatedDate] [datetime] NULL,
	[Status] [varchar](20) NULL,
	[Count] [int] NULL,
 CONSTRAINT [PK_StockInHeader] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[StockTransaction]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StockTransaction](
	[StockTranId] [int] IDENTITY(1,1) NOT NULL,
	[TranDate] [nvarchar](100) NULL,
	[ProductId] [bigint] NOT NULL,
	[Opening] [int] NULL,
	[Purchase] [int] NULL,
	[Refund] [int] NULL,
	[Sale] [int] NULL,
	[Consignment] [int] NULL,
	[Month] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[AdjustmentStockIn] [int] NULL,
	[AdjustmentStockOut] [int] NULL,
	[ConversionStockIn] [int] NULL,
	[ConversionStockOut] [int] NULL,
	[StockIn] [int] NULL,
	[StockOut] [int] NULL,
 CONSTRAINT [PK_StockTransaction] PRIMARY KEY CLUSTERED 
(
	[StockTranId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Supplier]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Supplier](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL,
	[PhoneNumber] [nvarchar](50) NULL,
	[Address] [nvarchar](200) NULL,
	[Email] [varchar](100) NULL,
	[ContactPerson] [nvarchar](200) NULL,
 CONSTRAINT [PK_Supplier] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Tax]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tax](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[TaxPercent] [decimal](5, 2) NULL,
	[IsDelete] [bit] NULL,
 CONSTRAINT [PK_Tax] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Ticket]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Ticket](
	[Id] [varchar](20) NOT NULL,
	[TicketNo] [varchar](20) NOT NULL,
	[TransactionDetailId] [bigint] NOT NULL,
	[Status] [bit] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[EnteranceDate] [datetime] NULL,
	[Category] [varchar](50) NULL,
	[ReadCount] [bigint] NULL,
	[UserDefinded] [nvarchar](200) NULL,
	[isDelete] [bit] NULL,
	[UserName] [nvarchar](200) NULL,
	[DeletedDate] [datetime] NULL,
	[RePrint] [int] NULL,
	[PlaceStatus] [nvarchar](50) NULL,
 CONSTRAINT [PK_Ticket] PRIMARY KEY CLUSTERED 
(
	[Id] ASC,
	[TicketNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TicketButtonAssign]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TicketButtonAssign](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ButtonName] [nvarchar](200) NOT NULL,
	[ButtonText] [nvarchar](50) NULL,
	[Assignproductid] [bigint] NULL,
	[Defined] [int] NULL,
	[Defined1] [nvarchar](300) NULL,
 CONSTRAINT [PK_TicketButtonAssign] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Townshipdb]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Townshipdb](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TownshipName] [varchar](100) NULL,
 CONSTRAINT [PK_Townshipdb] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Transaction]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Transaction](
	[Id] [varchar](20) NOT NULL,
	[DateTime] [datetime] NULL,
	[UserId] [int] NULL,
	[CounterId] [int] NULL,
	[Type] [varchar](20) NULL,
	[IsPaid] [bit] NULL,
	[IsComplete] [bit] NULL,
	[IsActive] [bit] NULL,
	[IsDeleted] [bit] NULL,
	[PaymentTypeId] [int] NULL,
	[TaxAmount] [int] NULL,
	[DiscountAmount] [int] NULL,
	[TotalAmount] [bigint] NULL,
	[RecieveAmount] [bigint] NULL,
	[ParentId] [varchar](20) NULL,
	[GiftCardId] [int] NULL,
	[CustomerId] [int] NULL,
	[MCDiscountAmt] [decimal](18, 2) NULL,
	[BDDiscountAmt] [decimal](18, 2) NULL,
	[MemberTypeId] [int] NULL,
	[MCDiscountPercent] [decimal](5, 2) NULL,
	[ReceivedCurrencyId] [int] NULL,
	[IsSettlement] [bit] NULL,
	[TranVouNos] [varchar](1000) NULL,
	[IsWholeSale] [bit] NULL,
	[GiftCardAmount] [decimal](18, 2) NULL,
	[ShopId] [int] NULL,
	[UpdatedDate] [datetime] NULL,
	[Note] [nvarchar](max) NULL,
	[TableIdOrQue] [int] NULL,
	[ServiceFee] [int] NULL,
 CONSTRAINT [PK_Transaction] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TransactionDetail]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TransactionDetail](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[TransactionId] [varchar](20) NULL,
	[ProductId] [bigint] NULL,
	[Qty] [int] NULL,
	[UnitPrice] [bigint] NULL,
	[DiscountRate] [decimal](5, 2) NOT NULL,
	[TaxRate] [decimal](5, 2) NOT NULL,
	[TotalAmount] [bigint] NULL,
	[IsDeleted] [bit] NULL,
	[ConsignmentPrice] [bigint] NULL,
	[IsConsignmentPaid] [bit] NULL,
	[IsFOC] [bit] NULL,
	[SellingPrice] [bigint] NULL,
 CONSTRAINT [PK_TransactionDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Turnstile]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Turnstile](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](200) NOT NULL,
	[SerialNo] [int] NOT NULL,
	[IP] [varchar](50) NOT NULL,
	[Port] [int] NOT NULL,
	[door] [int] NOT NULL,
	[status] [bit] NOT NULL,
	[ServerID] [int] NOT NULL,
	[UserDefinded] [nvarchar](200) NULL,
	[onoff] [bit] NOT NULL,
	[PlaceStatus] [nvarchar](50) NULL,
 CONSTRAINT [PK_Turnstile] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TurnStileServer]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TurnStileServer](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](200) NOT NULL,
	[ServerIP] [varchar](50) NOT NULL,
	[Port] [int] NOT NULL,
	[UserDefinded] [nvarchar](200) NULL,
 CONSTRAINT [PK_TurnStileServer] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Unit]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Unit](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UnitName] [nvarchar](50) NULL,
 CONSTRAINT [PK_Unit] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UnitConversion]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UnitConversion](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FromProductId] [int] NOT NULL,
	[FromQty] [numeric](18, 2) NOT NULL,
	[ToProductId] [int] NOT NULL,
	[ToQty] [numeric](18, 2) NOT NULL,
	[ConversionDate] [datetime] NOT NULL,
	[OnePackQty] [numeric](18, 2) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [int] NULL,
	[NormalPurchaseDetailId] [int] NOT NULL,
	[MaximumPurchaseDetailId] [varchar](100) NOT NULL,
	[NormalUnitPurchasePrice] [int] NULL,
 CONSTRAINT [PK_UnitConversion] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UsePrePaidDebt]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UsePrePaidDebt](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CreditTransactionId] [varchar](20) NULL,
	[PrePaidDebtTransactionId] [varchar](20) NULL,
	[UseAmount] [int] NULL,
	[CashierId] [int] NULL,
	[CounterId] [int] NULL,
 CONSTRAINT [PK_UsePrePaidDebt] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[User]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[User](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL,
	[UserRoleId] [int] NULL,
	[Password] [varchar](max) NULL,
	[DateTime] [datetime] NULL,
	[ShopId] [int] NULL,
	[MenuPermission] [nvarchar](100) NULL,
	[UserCodeNo] [nvarchar](500) NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedBy] [int] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserRole]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserRole](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [varchar](50) NULL,
 CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WrapperItem]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WrapperItem](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ParentProductId] [bigint] NULL,
	[ChildProductId] [bigint] NULL,
	[ChildQty] [int] NULL,
	[IsDelete] [bit] NULL,
 CONSTRAINT [PK_WrapperItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[Authorize] ON 

INSERT [dbo].[Authorize] ([Id], [licenseKey], [macAddress]) VALUES (1, N'5F/JCrEHxhgzUXVd7ce/fcBaIzWVRFE3zPgThNyw2UxEmQMTTL4OEQ==', N'CNdkV8AioqxmOtTwSehUUK3r17a3MtWr')
SET IDENTITY_INSERT [dbo].[Authorize] OFF
SET IDENTITY_INSERT [dbo].[City] ON 

INSERT [dbo].[City] ([Id], [CityName], [IsDelete]) VALUES (1, N'Yangon', 0)
SET IDENTITY_INSERT [dbo].[City] OFF
SET IDENTITY_INSERT [dbo].[Counter] ON 

INSERT [dbo].[Counter] ([Id], [Name], [IsDelete]) VALUES (1, N'One', 0)
SET IDENTITY_INSERT [dbo].[Counter] OFF
SET IDENTITY_INSERT [dbo].[Currency] ON 

INSERT [dbo].[Currency] ([Id], [Country], [Symbol], [CurrencyCode], [LatestExchangeRate]) VALUES (1, N'Myanmar', N'Ks', N'MMK', 1)
INSERT [dbo].[Currency] ([Id], [Country], [Symbol], [CurrencyCode], [LatestExchangeRate]) VALUES (2, N'United State of America', N'$', N'USD', 1000)
SET IDENTITY_INSERT [dbo].[Currency] OFF
SET IDENTITY_INSERT [dbo].[Customer] ON 

INSERT [dbo].[Customer] ([Id], [Title], [Name], [PhoneNumber], [Address], [NRC], [Email], [CityId], [TownShip], [Gender], [Birthday], [MemberTypeID], [VIPMemberId], [StartDate], [CustomerCode], [CustomerTypeId], [PromoteDate]) VALUES (1, N'Mr', N'Default', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, N'CuMO000001', NULL, NULL)
SET IDENTITY_INSERT [dbo].[Customer] OFF
SET IDENTITY_INSERT [dbo].[ExpenseCategory] ON 

INSERT [dbo].[ExpenseCategory] ([Id], [Name], [IsDelete]) VALUES (1, N'Salary', 0)
INSERT [dbo].[ExpenseCategory] ([Id], [Name], [IsDelete]) VALUES (2, N'Utilities', 0)
INSERT [dbo].[ExpenseCategory] ([Id], [Name], [IsDelete]) VALUES (3, N'Rent', 0)
SET IDENTITY_INSERT [dbo].[ExpenseCategory] OFF
SET IDENTITY_INSERT [dbo].[PaymentType] ON 

INSERT [dbo].[PaymentType] ([Id], [Name]) VALUES (1, N'Cash')
INSERT [dbo].[PaymentType] ([Id], [Name]) VALUES (2, N'Credit')
INSERT [dbo].[PaymentType] ([Id], [Name]) VALUES (3, N'GiftCard')
INSERT [dbo].[PaymentType] ([Id], [Name]) VALUES (4, N'FOC')
INSERT [dbo].[PaymentType] ([Id], [Name]) VALUES (5, N'MPU')
INSERT [dbo].[PaymentType] ([Id], [Name]) VALUES (6, N'Tester')
SET IDENTITY_INSERT [dbo].[PaymentType] OFF
SET IDENTITY_INSERT [dbo].[pjForms] ON 

INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (1, N'AddNote', N'Add Note For Current Transaction', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (2, N'AddPackageChild', N'AddPackageChild', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (3, N'AddTable', N'AddTable', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (4, N'AdjustmentDeleteLog', N'Adjustment Delete Log', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (5, N'AdjustmentFrm', N'Adjustment', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (6, N'AdjustmentListFrm', N'Adjustment List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (7, N'AdjustmentRpt', N'Adjustment Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (8, N'AdjustmentTypefrm', N'Type', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (9, N'AssignTicketButton', N'AssignTicketButton', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (10, N'NoveltiesSaleReport', N'Novelties Sale Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (11, N'frmPaidByCredit', N'Paid By Credit', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (12, N'GWPTransactionsReport', N'GWP Transactions', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (13, N'AverageMonthlySaleReport_frm', N'AverageMonthlySaleReport_frm', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (14, N'Barcode', N'Barcode', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (15, N'Brand', N'Add New Brand', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (16, N'Centralized', N'Centralized', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (17, N'chart', N'Dashboard', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (18, N'City', N'City', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (19, N'ConsignmentSettlement', N'Consignment Settlement', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (20, N'ConsignmentProductCounter', N'Add Consignor', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (21, N'ConsignmentProductReport', N'Consignment Sale Product Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (22, N'ConsignmentSettlementList', N'Consignment Settlement List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (23, N'ConsignmentSettlementReport', N'Consignment Settlement Report', N'', 0)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (24, N'ConsignmentSettlement_DetailList', N'Consignment Settlement Detail List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (25, N'frmlocalize', N'Ctrl Localize', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (26, N'csvExportImport', N'CSV Export&Import', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (27, N'Customer_Package_detail', N'Customer_Package_detail', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (28, N'CustomerDetailInfoExample', N'CustomerDetailInfoExample', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (29, N'exampleSale', N'exampleSale', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (30, N'ExchangeRate', N'ExchangeRate', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (31, N'ExpenseCategory', N'Add New Expense Category', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (32, N'ExpenseDeleteLog', N'Expense Delete Log', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (33, N'ExpenseDetailList', N'Expense Detial List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (34, N'ExpenseEntry', N'Create Expense', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (35, N'ExpenseList', N'Expense List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (36, N'ExpenseReport', N'ExpenseReport', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (37, N'GeneralPassword', N'GeneralPassword', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (38, N'NoveltySystem', N'Novelty System', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (39, N'Novelty_Detail', N'Novelty Sytem Detail', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (40, N'Novelty_List', N'Novelty List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (41, N'ProductExpireReport', N'Product Expire Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (42, N'Promotion_List', N'Promotion System List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (43, N'PromotionDetail', N'Promotion Detail', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (44, N'PromotionSystem', N'Promotion System', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (45, N'StockAgingReport', N'Stock Aging Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (46, N'VersionInfo', N'Version Info', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (47, N'frmNetIncomeReport', N'Net Income Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (48, N'frmSale_FOC', N'FOC', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (49, N'GiftCardTransactionHistory', N'Gift Card Transaction Hisotry', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (50, N'MDIParent', N'mPOS', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (51, N'MemberRule', N'Add Member Card Rule', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (52, N'newMemberType', N'Add Member Card Type', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (53, N'mType', N'New Member', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (54, N'OutstandingSupplierDetail', N'Outstanding Supplier Detail', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (55, N'OutstandingSupplierList', N'Outstanding Supplier List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (56, N'Package_Customer_List', N'Package_Customer_List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (57, N'ProductDetailQty', N'Product Quantity Change History', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (58, N'ProfitAndLoss_frm', N'Gross Profit / Loss Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (59, N'PurchaseDeleteLog_frm', N'Delete Log Form', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (60, N'Counter', N'Add New Counter', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (61, N'CreditTransactionList', N'Credit Transaction List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (62, N'CustomerDetail', N'Customer Detail', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (63, N'CustomerDetailInfo', N'Customer Detail Infomation', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (64, N'CustomerList', N'Customer List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (65, N'DailyTotalReport', N'Daily Total Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (66, N'DeleteLogForm', N'Delete Log Form', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (67, N'DraftDetail', N'DraftDetail', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (68, N'DraftList', N'DraftList', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (69, N'EndDay', N'EndDay', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (70, N'FrmCustomerInfomation', N'Customer Infomation Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (71, N'frmCustomerSaleReport', N'Customer Sales Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (72, N'GiftCardControl', N'Add New GiftCard', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (73, N'ItemList', N'Product List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (74, N'ItemSummary', N'Item  Sale Summary Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (75, N'DailySummaryReport', N'Daily Summary Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (76, N'Login', N'Login', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (77, N'NewCustomer', N'Add New Customer', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (78, N'NewProduct', N'Add New Product', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (79, N'NewSupplier', N'Add New Supplier', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (80, N'NewUser', N'Add New User', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (81, N'OutstandingCustomerList', N'Outstanding Customer List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (82, N'OutstandingCustomerReport', N'Outstanding Customer Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (83, N'PaidByCash2', N'PaidByCash', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (84, N'PaidByCreditWithPrePaidDebt', N'PaidBy Credit', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (85, N'PaidByFOC', N'PaidByFOC', N'', 0)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (86, N'PaidByGiftCard', N'PaidByGiftCard', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (87, N'PaidByMPU', N'PaidByMPU', N'', 0)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (88, N'PriceChangeHistoryList', N'Price Change History List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (89, N'PrintBarcode', N'PrintBarcode', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (90, N'ProductCategory', N'Product Category', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (91, N'ProductDetailPrice', N'Product Price Change History', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (92, N'ProductReport_frm', N'Product Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (93, N'ProductSubCategory', N'Product Sub Category', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (94, N'PurchaseDetailList', N'Purchasing Detial List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (95, N'PurchaseDiscountReport_frm', N'Purchase Discount Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (96, N'PurchaseInput', N'Purchase Order', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (97, N'PurchaseListBySupplier', N'Purchasing List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (98, N'PurchaseOrderItem', N'Reorder Point Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (99, N'PurchaseReport', N'Purchase Report', N'', 1)
GO
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (100, N'RefundDetail', N'RefundDetail', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (101, N'RefundDiscount', N'Discount', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (102, N'RefundList', N'Refund List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (103, N'RefundTransaction', N'RefundTransaction', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (104, N'Register', N'Register', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (105, N'RoleManagement', N'Role Management', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (106, N'SaleBreakDown', N'Sale Breakdown Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (107, N'Sales', N'Sales', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (108, N'Setting', N'Setting', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (109, N'Shop', N'Add New Shop', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (110, N'StartDay', N'StartDay', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (111, N'StockReceiveList', N'Stock In/Transfer/Return List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (112, N'StockTransaction', N'Stock Transaction', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (113, N'StockTransactionReport', N'StockTransactionReport', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (114, N'StockTransReturnForm', N'Stock Transaction', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (115, N'SupplierInformation', N'SupplierInformation', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (116, N'SupplierList', N'SupplierList', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (117, N'Taxes', N'Taxes', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (118, N'TaxesSummary', N'Tax Summary Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (119, N'TopSaleReport', N' Best Seller Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (120, N'TopUp', N'TopUp', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (121, N'Transaction_Reports', N' Transaction Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (122, N'TransactionDetailByItem', N'Transaction Detail Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (123, N'TransactionDetailForm', N'Transaction Detail', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (124, N'TransactionList', N'Transaction List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (125, N'TransactionReportByCashierOrCounter', N'TransactionReportByCashierOrCounter', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (126, N'TransactionReport_FOC_MPU', N'Transaction Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (127, N'TransactionSummary', N'Transaction Summary Report', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (128, N'UnitConversionfrm', N'Stock Unit Conversion', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (129, N'UnitConversionListfrm', N'Stock Unit Conversion List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (130, N'UnitForm', N'Measurement Unit', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (131, N'UserControl', N'User List', N'', 1)
INSERT [dbo].[pjForms] ([Id], [Name], [TextEng], [TextMyanmar], [AllowToLoad]) VALUES (132, N'ViewTicket', N'ViewTicket', N'', 1)
SET IDENTITY_INSERT [dbo].[pjForms] OFF
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1, 1, N'label1', N'Label', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (2, 2, N'label1', N'Label', N'Qty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (3, 2, N'dgvChildItems', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (4, 3, N'label2', N'Label', N'Table No', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (5, 3, N'dgvTable', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (6, 3, N'label1', N'Label', N'Table No', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (7, 3, N'groupBox3', N'GroupBox', N'Search', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (8, 3, N'groupBox2', N'GroupBox', N'Table List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (9, 3, N'groupBox1', N'GroupBox', N'Add Table', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (10, 4, N'label4', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (11, 4, N'lblStockOut', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (12, 4, N'label7', N'Label', N'Type   :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (13, 4, N'label5', N'Label', N'Total Stock Out   :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (14, 4, N'lblStockIn', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (15, 4, N'label1', N'Label', N'Total Stock In   :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (16, 4, N'dgvAdjustmentDeleteLog', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (17, 4, N'label3', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (18, 4, N'label2', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (19, 4, N'groupBox4', N'GroupBox', N'By Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (20, 4, N'groupBox3', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (21, 4, N'groupBox2', N'GroupBox', N'Adjustment Delete', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (22, 4, N'groupBox1', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (23, 5, N'label1', N'Label', N'* Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (24, 5, N'label5', N'Label', N'* Product Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (25, 5, N'label4', N'Label', N'* Adjustment Qty:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (26, 5, N'label6', N'Label', N'* Responsible Person', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (27, 5, N'label7', N'Label', N' Reason', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (28, 5, N'label8', N'Label', N'* Adjustment Date', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (29, 5, N'label3', N'Label', N'* Unit Price  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (30, 5, N'label13', N'Label', N'* Mandatory Fileds', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (31, 6, N'rdoApproved', N'Radio', N'Approved', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (32, 6, N'rdoPending', N'Radio', N'Pending', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (33, 6, N'label5', N'Label', N'Total Stock Out    :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (34, 6, N'label3', N'Label', N'Total Stock In   :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (35, 6, N'lblStockOut', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (36, 6, N'lblStockIn', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (37, 6, N'label7', N'Label', N'Type  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (38, 6, N'label6', N'Label', N'Brand :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (39, 6, N'rdoAll', N'Radio', N'All', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (40, 6, N'rdNonConsignment', N'Radio', N'Non-Consignment Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (41, 6, N'rdConsignment', N'Radio', N'Consignment Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (42, 6, N'dgvAdjustmentList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (43, 6, N'label1', N'Label', N'From:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (44, 6, N'label2', N'Label', N'To:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (45, 6, N'groupBox3', N'GroupBox', N'By Status', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (46, 6, N'groupBox1', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (47, 6, N'groupBox4', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (48, 6, N'groupBox2', N'GroupBox', N'Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (49, 6, N'GpDamageList', N'GroupBox', N'Adjustment List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (50, 6, N'GpSearchByPeriod', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (51, 7, N'label1', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (52, 7, N'label7', N'Label', N'Type   :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (53, 7, N'label6', N'Label', N'Brand :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (54, 7, N'rdoAll', N'Radio', N'All', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (55, 7, N'rdNonConsignment', N'Radio', N'Non-Consignment Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (56, 7, N'rdConsignment', N'Radio', N'Consignment Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (57, 7, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (58, 7, N'label3', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (59, 7, N'label2', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (60, 7, N'groupBox5', N'GroupBox', N'By Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (61, 7, N'groupBox4', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (62, 7, N'groupBox2', N'GroupBox', N'Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (63, 7, N'groupBox3', N'GroupBox', N'Adjustment Report', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (64, 7, N'groupBox1', N'GroupBox', N'Select By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (65, 8, N'dgvAdjustmentTypeList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (66, 8, N'label1', N'Label', N'Name  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (67, 8, N'groupBox2', N'GroupBox', N'Type  List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (68, 8, N'groupBox1', N'GroupBox', N'Add New Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (69, 9, N'label2', N'Label', N'Button', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (70, 9, N'label1', N'Label', N'Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (71, 9, N'dgvButtons', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (72, 10, N'label8', N'Label', N'City', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (73, 10, N'lblCounterName', N'Label', N'Counter Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (74, 10, N'rdbNon_VIP', N'Radio', N'Non VIP', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (75, 10, N'rdoAll', N'Radio', N'All', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (76, 10, N'rdbVIP', N'Radio', N'VIP', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (77, 10, N'label2', N'Label', N'From Date/ To Date', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (78, 10, N'label1', N'Label', N'Novelty List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (79, 10, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (80, 10, N'groupBox4', N'GroupBox', N'Select City And Cuounter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (81, 10, N'groupBox2', N'GroupBox', N'By One Select', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (82, 10, N'groupBox1', N'GroupBox', N'Novelties List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (83, 10, N'groupBox3', N'GroupBox', N'Novelties Sale Report', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (84, 11, N'lblChangesText', N'Label', N'Changes', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (85, 11, N'lblBank', N'Label', N'Bank Payment', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (86, 11, N'label3', N'Label', N'Payment Method', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (87, 11, N'lblChanges', N'Label', N'0.00', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (88, 11, N'lblTotalCost', N'Label', N'0.00', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (89, 11, N'label5', N'Label', N'Total Cost', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (90, 11, N'label2', N'Label', N'Recieve Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (91, 11, N'label1', N'Label', N'Currency', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (92, 12, N'label1', N'Label', N'Counter Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (93, 12, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (94, 12, N'label4', N'Label', N'Member Type:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (95, 12, N'label3', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (96, 12, N'label2', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (97, 12, N'groupBox4', N'GroupBox', N'Select Cuounter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (98, 12, N'groupBox3', N'GroupBox', N'GWP Transactions Report', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (99, 12, N'groupBox2', N'GroupBox', N'By One Select', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (100, 12, N'groupBox1', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (101, 13, N'label4', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (102, 13, N'label1', N'Label', N'Year :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (103, 13, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (104, 13, N'label2', N'Label', N'Brand :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (105, 13, N'label3', N'Label', N'Counter :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (106, 13, N'groupBox5', N'GroupBox', N'By shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (107, 13, N'groupBox2', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (108, 13, N'groupBox1', N'GroupBox', N'Average Monthly Sale Report', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (109, 13, N'groupBox3', N'GroupBox', N'By Brand', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (110, 13, N'groupBox4', N'GroupBox', N'By Counter :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (111, 14, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (112, 14, N'label2', N'Label', N'Rows', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (113, 14, N'label1', N'Label', N'Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (114, 15, N'dgvBrandList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (115, 15, N'label1', N'Label', N'Name  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (116, 15, N'groupBox2', N'GroupBox', N'Brand List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (117, 15, N'groupBox1', N'GroupBox', N'Add New Brand', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (118, 16, N'label2', N'Label', N'Month To Export', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (119, 16, N'label1', N'Label', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (120, 17, N'lbltotal', N'Label', N'Total', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (121, 17, N'dailysale', N'Chart', N'Daily Sale Summary', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (122, 17, N'label3', N'Label', N'DashBoard', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (123, 17, N'label2', N'Label', N'Your Accounts At a Glance', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (124, 17, N'label6', N'Label', N'Account Payable', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (125, 17, N'lblPayable', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (126, 17, N'label5', N'Label', N'Account Receivable', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (127, 17, N'lblReceivable', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (128, 17, N'label8', N'Label', N'Min Balance Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (129, 17, N'label7', N'Label', N'Net Income', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (130, 17, N'lblNetgain', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (131, 17, N'label1', N'Label', N'DashBoard', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (132, 17, N'Product', N'Chart', N'Monthly Best Seller Top 10 Products', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (133, 17, N'Mothly Sale Breakdown by Category', N'Chart', N'Mothly Sale Breakdown by Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (134, 18, N'dgvCityList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (135, 18, N'label1', N'Label', N'Name  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (136, 18, N'groupBox2', N'GroupBox', N'City List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (137, 18, N'groupBox1', N'GroupBox', N'Add New City', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (138, 19, N'txtdefaultshopname', N'Label', N'.', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (139, 19, N'label6', N'Label', N'From :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (140, 19, N'label3', N'Label', N'&Consignment Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (141, 19, N'label2', N'Label', N'&To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (142, 19, N'label1', N'Label', N'&From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (143, 19, N'label4', N'Label', N'Co&mment   :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (144, 19, N'txtTotalProfitAmt', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (145, 19, N'label5', N'Label', N'Total Profit Amount     :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (146, 19, N'txtTotalConsignPaidAmt', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (147, 19, N'label11', N'Label', N'Total Consignment Settlement Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (148, 19, N'groupBox1', N'GroupBox', N'Select Counter:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (149, 19, N'dgvConsingmentPaid', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (150, 19, N'groupBox2', N'GroupBox', N'Transaction Period :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (151, 20, N'dgvCosignmentCounterList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (152, 20, N'label1', N'Label', N'Name  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (153, 20, N'label3', N'Label', N'Phone No :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (154, 20, N'label4', N'Label', N'Email :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (155, 20, N'label2', N'Label', N'Address :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (156, 20, N'groupBox2', N'GroupBox', N'Cosignment Counter List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (157, 20, N'groupBox1', N'GroupBox', N'Add Consignment Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (158, 21, N'label4', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (159, 21, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (160, 21, N'label3', N'Label', N'Consignment Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (161, 21, N'label2', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (162, 21, N'label1', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (163, 21, N'groupBox3', N'GroupBox', N'By Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (164, 21, N'groupBox1', N'GroupBox', N'Select Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (165, 21, N'groupBox2', N'GroupBox', N'Report Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (166, 22, N'label3', N'Label', N'&Consignment Counter :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (167, 22, N'label5', N'Label', N'Shop :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (168, 22, N'txtTotalSettlementAmount', N'Label', N'Total Settlement Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (169, 22, N'label2', N'Label', N'Total Settlement Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (170, 22, N'label1', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (171, 22, N'label6', N'Label', N'Settlement Year :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (172, 22, N'label4', N'Label', N'Settlement &Month:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (173, 22, N'groupBox3', N'GroupBox', N'By Counter And Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (174, 22, N'groupBox2', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (175, 22, N'dgvConSettlementList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (176, 22, N'groupBox1', N'GroupBox', N'Choose Year And Month', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (177, 24, N'txtTotalProfitAmt', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (178, 24, N'txtTotalConsignmentAmt', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (179, 24, N'txtTotalSellingAmt', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (180, 24, N'lblTotalProfitAmt', N'Label', N'Total Profit Amount:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (181, 24, N'lblTotalConsignmentAmt', N'Label', N'Total Consignment Amount:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (182, 24, N'lblTotalSellingPrice', N'Label', N'Total Selling Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (183, 24, N'lblTotalQuantity', N'Label', N'Total Quantity :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (184, 24, N'txtTotalQuantity', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (185, 24, N'dgvConsignmentDetail', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (186, 24, N'lblConsignor', N'Label', N'Consignor  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (187, 24, N'lblConsignmentNo', N'Label', N'Consignment No. :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (188, 24, N'txtConsignor', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (189, 24, N'txtConsignmentNo', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (190, 24, N'lblSettlementDate', N'Label', N'Settlement Date  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (191, 24, N'txtSettlementDate', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (192, 24, N'groupBox1', N'GroupBox', N'Consignment Settlement Product List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (193, 25, N'lbllanguage', N'Label', N'Processing Language', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (194, 25, N'label2', N'Label', N'Control Type :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (195, 25, N'label1', N'Label', N'Form :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (196, 25, N'dgvctlLocalize', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (197, 25, N'gbLanguage', N'GroupBox', N'Language  File', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (198, 26, N'lblstatus', N'Label', N'Ready', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (199, 26, N'dgvImport', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (200, 26, N'gbimported', N'GroupBox', N'Imported product', N'', N'', N'', N'', 1)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (201, 27, N'dgvOutstandingTransaction', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (202, 27, N'dgvOldTransaction', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (203, 27, N'label6', N'Label', N'Remaining Balance :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (204, 27, N'label7', N'Label', N'Total Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (205, 27, N'lblAddress', N'Label', N'Address :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (206, 27, N'label10', N'Label', N'Birthday :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (207, 27, N'lblBirthday', N'Label', N'Phone Number :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (208, 27, N'label11', N'Label', N'Gender :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (209, 27, N'lblGender', N'Label', N'NRC :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (210, 27, N'label4', N'Label', N'Address :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (211, 27, N'label12', N'Label', N'City :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (212, 27, N'lblCity', N'Label', N'Address :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (213, 27, N'lblNrc', N'Label', N'NRC :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (214, 27, N'lblPhoneNumber', N'Label', N'Phone Number :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (215, 27, N'lblName', N'Label', N'Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (216, 27, N'lblEmail', N'Label', N'Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (217, 27, N'label1', N'Label', N'Customer Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (218, 27, N'label9', N'Label', N'Email :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (219, 27, N'label2', N'Label', N'Phone Number :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (220, 27, N'label3', N'Label', N'NRC :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (221, 27, N'label5', N'Label', N'Package', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (222, 28, N'lblBirthday', N'Label', N'Bithday :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (223, 28, N'label4', N'Label', N'Address :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (224, 28, N'label10', N'Label', N'Birthday :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (225, 28, N'lblAddress', N'Label', N'Address :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (226, 28, N'label12', N'Label', N'City :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (227, 28, N'lblCity', N'Label', N'City :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (228, 28, N'label9', N'Label', N'Email :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (229, 28, N'lblEmail', N'Label', N'Email :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (230, 28, N'label2', N'Label', N'Phone Number :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (231, 28, N'lblPhoneNumber', N'Label', N'Phone Number :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (232, 28, N'lblMType', N'Label', N'Member Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (233, 28, N'lblMCId', N'Label', N'Member Card Id', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (234, 28, N'lblName', N'Label', N'Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (235, 28, N'lblGender', N'Label', N'Gender :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (236, 28, N'label1', N'Label', N'Customer Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (237, 28, N'label11', N'Label', N'Gender :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (238, 28, N'label3', N'Label', N'NRC :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (239, 28, N'lblNrc', N'Label', N'NRC :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (240, 28, N'label5', N'Label', N'Member Card Id', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (241, 28, N'label6', N'Label', N'Member Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (242, 29, N'txtUnitPrice', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (243, 29, N'label17', N'Label', N'* Qty :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (244, 29, N'label18', N'Label', N'* Product Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (245, 29, N'label19', N'Label', N'* Barcode :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (246, 29, N'label4', N'Label', N'Total Discount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (247, 29, N'label16', N'Label', N'Member Card Discount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (248, 29, N'label5', N'Label', N'Total Tax', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (249, 29, N'lblTotal', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (250, 29, N'lblDiscountTotal', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (251, 29, N'lblTaxTotal', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (252, 29, N'label3', N'Label', N'Sub Total', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (253, 29, N'label6', N'Label', N'&Discount Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (254, 29, N'label7', N'Label', N'Pa&yment Method', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (255, 29, N'label12', N'Label', N'Total Qty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (256, 29, N'lblTotalQty', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (257, 29, N'label8', N'Label', N'Tax Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (258, 29, N'dgvSearchProductList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (259, 29, N'label9', N'Label', N'N&ame :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (260, 29, N'label10', N'Label', N'Balance :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (261, 29, N'label2', N'Label', N'Available Package ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (262, 29, N'gbFOC', N'GroupBox', N'FOC', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (263, 29, N'chkPrintSlip', N'CheckBox', N'Print Slip', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (264, 29, N'chkWholeSale', N'CheckBox', N'Whole Sale', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (265, 29, N'dgvSalesItem', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (266, 29, N'lblNRIC', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (267, 29, N'label15', N'Label', N'&Member ID Number   :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (268, 29, N'lblMemberType', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (269, 29, N'label1', N'Label', N'S&elect Customer        :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (270, 29, N'gbSearchProduct', N'GroupBox', N'Search Product Code By Product Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (271, 29, N'label11', N'Label', N'Birthday   :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (272, 29, N'lblBirthday', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (273, 29, N'label13', N'Label', N'NRIC        :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (274, 30, N'label1', N'Label', N' = 1Ks', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (275, 30, N'label12', N'Label', N'Exchange Rate', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (276, 30, N'label13', N'Label', N'Currency', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (277, 30, N'groupBox6', N'GroupBox', N'Edit Exchange Rate', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (278, 31, N'dgvExpCagList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (279, 31, N'label1', N'Label', N'Name  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (280, 31, N'groupBox2', N'GroupBox', N'Expense Category List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (281, 31, N'groupBox1', N'GroupBox', N'Add Expense Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (282, 32, N'Shop', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (283, 32, N'lblsName', N'Label', N'Expense Category:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (284, 32, N'dgvExpenseList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (285, 32, N'label3', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (286, 32, N'label2', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (287, 32, N'txtTotalExpenseAmt', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (288, 32, N'groupBox3', N'GroupBox', N'By Expense Category And Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (289, 32, N'label4', N'Label', N'Total Expense Amount  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (290, 32, N'groupBox2', N'GroupBox', N'Expense Delete', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (291, 32, N'groupBox1', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (292, 33, N'dgvExpenseList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (293, 33, N'label1', N'Label', N'Expense Category  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (294, 33, N'label2', N'Label', N'Expense No :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (295, 33, N'lblExpenseCag', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (296, 33, N'lblExpenseNo', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (297, 33, N'label3', N'Label', N'Expense Date :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (298, 33, N'lblExpenseDate', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (299, 33, N'txtTotalExpenseAmt', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (300, 33, N'label4', N'Label', N'Total Expense Amount  :', N'', N'', N'', N'', 1)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (301, 33, N'groupBox1', N'GroupBox', N'Expense Detail List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (302, 34, N'label8', N'Label', N'Comment', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (303, 34, N'label3', N'Label', N'* Expense Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (304, 34, N'label2', N'Label', N'Expense No :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (305, 34, N'label1', N'Label', N'Expense Date :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (306, 34, N'label7', N'Label', N'Total Expense Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (307, 34, N'label4', N'Label', N'* Description', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (308, 34, N'label5', N'Label', N'* Qty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (309, 34, N'label6', N'Label', N'* Price', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (310, 34, N'dgvExpenseList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (311, 34, N'groupBox2', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (312, 34, N'label13', N'Label', N'* Mandatory Fileds', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (313, 34, N'groupBox1', N'GroupBox', N'Add Description', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (314, 35, N'label1', N'Label', N'Shop Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (315, 35, N'label3', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (316, 35, N'label4', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (317, 35, N'rdoApproved', N'Radio', N'Approved', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (318, 35, N'rdoPending', N'Radio', N'Pending', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (319, 35, N'txtTotalExpenseAmt', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (320, 35, N'label2', N'Label', N'Total Expense Amount  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (321, 35, N'lblExpense', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (322, 35, N'lblsName', N'Label', N'Expense Category:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (323, 35, N'dgvExpenseList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (324, 35, N'groupBox5', N'GroupBox', N'By Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (325, 35, N'groupBox4', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (326, 35, N'groupBox3', N'GroupBox', N'By Status', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (327, 35, N'groupBox2', N'GroupBox', N'By Supplier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (328, 35, N'groupBox1', N'GroupBox', N'Expense List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (329, 36, N'label3', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (330, 36, N'label5', N'Label', N'Expense Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (331, 36, N'label2', N'Label', N'To :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (332, 36, N'label1', N'Label', N'From :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (333, 36, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (334, 36, N'groupBox4', N'GroupBox', N'By Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (335, 36, N'groupBox3', N'GroupBox', N'By Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (336, 36, N'groupBox2', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (337, 36, N'groupBox1', N'GroupBox', N'Expense List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (338, 37, N'lblMessage', N'Label', N'Please approve you are allowed current operation.', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (339, 37, N'label1', N'Label', N'Password', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (340, 38, N'label4', N'Label', N'Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (341, 38, N'dgvProductList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (342, 38, N'label1', N'Label', N'Line', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (343, 38, N'label2', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (344, 38, N'label3', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (345, 38, N'groupBox1', N'GroupBox', N'Product List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (346, 39, N'label1', N'Label', N'Period :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (347, 39, N'label2', N'Label', N'Line :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (348, 39, N'label3', N'Label', N'Product List :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (349, 39, N'lblPeriod', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (350, 39, N'lblLine', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (351, 39, N'dgvProductList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (352, 40, N'dgvNoveltyList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (353, 40, N'groupBox1', N'GroupBox', N'Novelty List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (354, 41, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (355, 41, N'expdays', N'Label', N'Expire in', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (356, 41, N'label5', N'Label', N'Current Date', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (357, 41, N'label3', N'Label', N'Sub Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (358, 41, N'label2', N'Label', N'Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (359, 41, N'label1', N'Label', N'Brand', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (360, 41, N'gbFilter', N'GroupBox', N'Search Filter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (361, 42, N'dgvPromotionList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (362, 43, N'lblGiftDiscount', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (363, 43, N'label27', N'Label', N'Gift Discount %', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (364, 43, N'lblGiftAmount', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (365, 43, N'label25', N'Label', N'Gift Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (366, 43, N'lblSaleTruePrice', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (367, 43, N'lblgiftProduct', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (368, 43, N'lblQty', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (369, 43, N'lblActive', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (370, 43, N'lblFilterProduct', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (371, 43, N'label15', N'Label', N'Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (372, 43, N'lblSubSegment', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (373, 43, N'label13', N'Label', N'Sub Segment', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (374, 43, N'lblSegment', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (375, 43, N'label11', N'Label', N'Segment', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (376, 43, N'lblLine', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (377, 43, N'label9', N'Label', N'Line', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (378, 43, N'lblPriceRange', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (379, 43, N'label7', N'Label', N'Price Range', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (380, 43, N'lblPeriod', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (381, 43, N'label5', N'Label', N'Effective Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (382, 43, N'lblType', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (383, 43, N'label3', N'Label', N'Promotion Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (384, 43, N'lblName', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (385, 43, N'label1', N'Label', N'Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (386, 43, N'label19', N'Label', N'Is Active?', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (387, 43, N'label17', N'Label', N'Gift Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (388, 43, N'label21', N'Label', N'Limited Qty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (389, 43, N'label23', N'Label', N'Sale True Price For Gift Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (390, 44, N'label20', N'Label', N'Gift Discount %', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (391, 44, N'label19', N'Label', N'Gift Cash Amount ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (392, 44, N'label18', N'Label', N'Sale True Value', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (393, 44, N'label8', N'Label', N'Select Gift Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (394, 44, N'rdbDiscount', N'Radio', N'Gift Discount%', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (395, 44, N'rdbGiftAmount', N'Radio', N'Gift Cash Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (396, 44, N'rdbGiftProduct', N'Radio', N'Gift Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (397, 44, N'label17', N'Label', N'Select Gift Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (398, 44, N'chkQty', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (399, 44, N'label15', N'Label', N'Have limited Promotion Qty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (400, 44, N'lblQty', N'Label', N'Available Qty', N'', N'', N'', N'', 1)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (401, 44, N'label9', N'Label', N'Have Product Size', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (402, 44, N'label16', N'Label', N'Have Product Qty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (403, 44, N'label21', N'Label', N'Is Active?', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (404, 44, N'chkIsActive', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (405, 44, N'chkSize', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (406, 44, N'chkFilterQty', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (407, 44, N'label22', N'Label', N'Size', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (408, 44, N'label23', N'Label', N'Qty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (409, 44, N'label11', N'Label', N'Select Line', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (410, 44, N'label12', N'Label', N'Select Segment', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (411, 44, N'label13', N'Label', N'Select Sub Segment', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (412, 44, N'label14', N'Label', N'Select Must Buy Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (413, 44, N'label10', N'Label', N'From Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (414, 44, N'lblToCost', N'Label', N'To Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (415, 44, N'rdbBetweenAmount', N'Radio', N'between two amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (416, 44, N'rdbOneAmount', N'Radio', N'Greather than one amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (417, 44, N'chkPriceRanges', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (418, 44, N'label7', N'Label', N'Have Price Range', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (419, 44, N'label6', N'Label', N'Terms And Conditions', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (420, 44, N'label5', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (421, 44, N'lblFrom', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (422, 44, N'label3', N'Label', N'Select Effective Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (423, 44, N'rdbPWP', N'Radio', N'Purchase With Purchase', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (424, 44, N'rdbGWP', N'Radio', N'Gift With Purchase', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (425, 44, N'label2', N'Label', N'Select Promotion Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (426, 44, N'label1', N'Label', N'Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (427, 45, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (428, 45, N'label5', N'Label', N'Current Date', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (429, 45, N'label3', N'Label', N'Sub Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (430, 45, N'label2', N'Label', N'Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (431, 45, N'label1', N'Label', N'Brand', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (432, 45, N'gbFilter', N'GroupBox', N'Search Filter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (433, 46, N'lblcontact2', N'Label', N'09785068097,09255282778', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (434, 46, N'lblcontact1', N'Label', N'dev@sourcecode.com.sg', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (435, 46, N'lblcontact', N'Label', N'Contacts :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (436, 46, N'lblproductversion', N'Label', N'0.0.0.0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (437, 46, N'label4', N'Label', N'Product Version :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (438, 46, N'lblcopyright', N'Label', N'Copyright © Sourcecode Co,Ltd 2018', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (439, 46, N'label3', N'Label', N'mPOS', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (440, 46, N'label2', N'Label', N'Product Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (441, 47, N'label2', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (442, 47, N'label3', N'Label', N'Month:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (443, 47, N'label1', N'Label', N'Year :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (444, 47, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (445, 47, N'groupBox1', N'GroupBox', N'By Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (446, 47, N'groupBox2', N'GroupBox', N'By Period:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (447, 48, N'txtUnitPrice', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (448, 48, N'label5', N'Label', N'* Qty :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (449, 48, N'label4', N'Label', N'* Product Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (450, 48, N'label14', N'Label', N'* Barcode :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (451, 49, N'lblTotalGiftCardAmt', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (452, 49, N'label1', N'Label', N'Total Gift Card Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (453, 49, N'dgvGiftTransactionList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (454, 50, N'fileMenu', N'MenuItem', N'&System', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (455, 50, N'accountToolStripMenuItem1', N'MenuItem', N'&Account', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (456, 50, N'addNewUserToolStripMenuItem', N'MenuItem', N'Add &New User', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (457, 50, N'userListToolStripMenuItem1', N'MenuItem', N'&User List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (458, 50, N'roleManagementToolStripMenuItem1', N'MenuItem', N'&Role Management', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (459, 50, N'customerToolStripMenuItem', N'MenuItem', N'&Customer', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (460, 50, N'addNewCustomerToolStripMenuItem', N'MenuItem', N'Add &New Customer', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (461, 50, N'customerListToolStripMenuItem1', N'MenuItem', N'Customer List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (462, 50, N'outstandingcustomerListToolStripMenuItem', N'MenuItem', N'&Outstanding Customer List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (463, 50, N'supplierToolStripMenuItem', N'MenuItem', N'S&upplier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (464, 50, N'addSupplierToolStripMenuItem', N'MenuItem', N'Add &New Supplier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (465, 50, N'supplierListToolStripMenuItem', N'MenuItem', N'&Supplier List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (466, 50, N'outstandingSupplierListToolStripMenuItem', N'MenuItem', N'&Outstanding Supplier List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (467, 50, N'purchasingToolStripMenuItem', N'MenuItem', N'Purc&hasing', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (468, 50, N'newPurchaseOrderToolStripMenuItem', N'MenuItem', N'&New Purchase Order', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (469, 50, N'purchaseHistoryToolStripMenuItem', N'MenuItem', N'Purchase List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (470, 50, N'purchaseDeleteLogToolStripMenuItem', N'MenuItem', N'Purchase Delete Log', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (471, 50, N'mainPromotionMenuItem', N'MenuItem', N'Promotion', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (472, 50, N'createpromotionSystemMenuItem', N'MenuItem', N'Promotion System', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (473, 50, N'listpromotionSystemListToolStripMenuItem', N'MenuItem', N'Promotion System List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (474, 50, N'createnoveltySystemToolStripMenuItem', N'MenuItem', N'Novelty System', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (475, 50, N'listnoveltySystemListToolStripMenuItem', N'MenuItem', N'Novelty System List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (476, 50, N'consignmentToolStripMenuItem', N'MenuItem', N'Consi&gnment', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (477, 50, N'consignmentSettlementToolStripMenuItem', N'MenuItem', N'Consignment S&ettlement', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (478, 50, N'consignmentSettlementListToolStripMenuItem', N'MenuItem', N'Consignment Settlement &List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (479, 50, N'productToolStripMenuItem', N'MenuItem', N'&Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (480, 50, N'productCategoryToolStripMenuItem1', N'MenuItem', N'Add Product &Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (481, 50, N'productSubCategoryToolStripMenuItem', N'MenuItem', N'Add Product &Sub Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (482, 50, N'brandToolStripMenuItem1', N'MenuItem', N'Add &Brand ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (483, 50, N'addNewProductToolStripMenuItem', N'MenuItem', N'Add &New Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (484, 50, N'productListToolStripMenuItem1', N'MenuItem', N'&Product List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (485, 50, N'productPriceChangeHistoryListToolStripMenuItem', N'MenuItem', N'Product Price Change &History List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (486, 50, N'stockUnitConversionToolStripMenuItem', N'MenuItem', N'Stock Unit Conversion', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (487, 50, N'stockUnitConversionListToolStripMenuItem', N'MenuItem', N'Stock Unit Conversion List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (488, 50, N'saleToolStripMenuItem', N'MenuItem', N'Sal&es', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (489, 50, N'saleToolStripMenuItem1', N'MenuItem', N'Sales', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (490, 50, N'transactionToolStripMenuItem1', N'MenuItem', N'&Transaction', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (491, 50, N'transactionListToolStripMenuItem1', N'MenuItem', N'Transaction &List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (492, 50, N'creditTransactionListToolStripMenuItem1', N'MenuItem', N'&Credit Transaction List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (493, 50, N'refundListToolStripMenuItem1', N'MenuItem', N'&Refund List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (494, 50, N'deleteLogToolStripMenuItem', N'MenuItem', N'&Delete Log', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (495, 50, N'adjustmentToolStripMenuItem', N'MenuItem', N'Stock A&djustment', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (496, 50, N'addNewadjustmentToolStripMenuItem', N'MenuItem', N'Add New Stock Adjustment', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (497, 50, N'adjustmentListToolStripMenuItem', N'MenuItem', N'Stock Adjustment List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (498, 50, N'adjustmentDeleteLogToolStripMenuItem', N'MenuItem', N'Stock Adjustment Delete Log', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (499, 50, N'expenseToolStripMenuItem', N'MenuItem', N'E&xpense', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (500, 50, N'createExpenseEntryToolStripMenuItem', N'MenuItem', N'&Create Expense Entry', N'', N'', N'', N'', 1)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (501, 50, N'expenseListToolStripMenuItem', N'MenuItem', N'Expense &List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (502, 50, N'expenseDeleteLogToolStripMenuItem', N'MenuItem', N'Expense &Delete Log', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (503, 50, N'stockManagementToolStripMenuItem', N'MenuItem', N'Stock Management', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (504, 50, N'stockInOutReturnToolStripMenuItem', N'MenuItem', N'Stock In/ Out/ Return', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (505, 50, N'stockTransactionListToolStripMenuItem', N'MenuItem', N'Stock Transaction List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (506, 50, N'centralizedToolStripMenuItem', N'MenuItem', N'Centralize', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (507, 50, N'settingsToolStripMenuItem1', N'MenuItem', N'&Settings', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (508, 50, N'configurationSettingToolStripMenuItem', N'MenuItem', N'Configuration (&Settings)', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (509, 50, N'counterToolStripMenuItem1', N'MenuItem', N'&Add Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (510, 50, N'addConsigmentCounterToolStripMenuItem', N'MenuItem', N'Add New Consignor', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (511, 50, N'giftCardContToolStripMenuItem', N'MenuItem', N'&Gift Card Control', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (512, 50, N'measurementUnitToolStripMenuItem', N'MenuItem', N'Add &Measurement Unit', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (513, 50, N'currencyExchangeToolStripMenuItem', N'MenuItem', N'Currency Exchange', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (514, 50, N'taxRatesToolStripMenuItem', N'MenuItem', N'Add &Tax Rates', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (515, 50, N'addCityToolStripMenuItem', N'MenuItem', N'Add &City', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (516, 50, N'addMemeberRuleToolStripMenuItem', N'MenuItem', N'Add Memeber &Rule', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (517, 50, N'addExpenseCategoryToolStripMenuItem', N'MenuItem', N'Add E&xpense Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (518, 50, N'addShopToolStripMenuItem', N'MenuItem', N'Add Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (519, 50, N'addTableToolStripMenuItem', N'MenuItem', N'Add Table', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (520, 50, N'cSVExportImportToolStripMenuItem', N'MenuItem', N'CSV Export/Import', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (521, 50, N'localizationToolStripMenuItem', N'MenuItem', N'Localization', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (522, 50, N'assignTicketToolStripMenuItem', N'MenuItem', N'Assign Ticket Buttons', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (523, 50, N'reportsToolStripMenuItem', N'MenuItem', N'&Reports', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (524, 50, N'dailySummaryToolStripMenuItem', N'MenuItem', N'Daily Sales Summary', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (525, 50, N'transactionToolStripMenuItem', N'MenuItem', N'&Transactions', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (526, 50, N'transactionSummaryToolStripMenuItem', N'MenuItem', N'Transaction &Summary', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (527, 50, N'transactionDetailByItemToolStripMenuItem', N'MenuItem', N'Transaction &Detail', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (528, 50, N'averageMonthlyReportToolStripMenuItem', N'MenuItem', N'&Average Monthly Report', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (529, 50, N'purchaseToolStripMenuItem', N'MenuItem', N'Purchasing', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (530, 50, N'purchaseDiscountToolStripMenuItem', N'MenuItem', N'Purchase Discount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (531, 50, N'itemSummaryToolStripMenuItem', N'MenuItem', N'&Item Sale Summary', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (532, 50, N'saleBreakDownToolStripMenuItem', N'MenuItem', N'Sale BreakDown', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (533, 50, N'taxesSummaryToolStripMenuItem', N'MenuItem', N'Ta&x Summary', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (534, 50, N'topToolStripMenuItem', N'MenuItem', N'&Best Seller Items', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (535, 50, N'customersSaleToolStripMenuItem', N'MenuItem', N'&Customer Sales', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (536, 50, N'outstandingCustomerReportToolStripMenuItem', N'MenuItem', N'&Outstanding Customer', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (537, 50, N'customerInfomationToolStripMenuItem', N'MenuItem', N'Customer Infomation', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (538, 50, N'productReportToolStripMenuItem', N'MenuItem', N'Product Report', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (539, 50, N'itemPurchaseOrderToolStripMenuItem', N'MenuItem', N'&Reorder Point', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (540, 50, N'consignmentCounterToolStripMenuItem', N'MenuItem', N'Consignment Sale Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (541, 50, N'profitAndLossToolStripMenuItem', N'MenuItem', N'Gross Profit/Loss', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (542, 50, N'AdjustmentReportToolStripMenuItem', N'MenuItem', N'Stock Adjustment', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (543, 50, N'expenseReportToolStripMenuItem', N'MenuItem', N'Expense Report', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (544, 50, N'stockTransactionToolStripMenuItem1', N'MenuItem', N'Stock Transaction', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (545, 50, N'netIncomeToolStripMenuItem', N'MenuItem', N'Net Income', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (546, 50, N'productexpiretoolStripMenuItem', N'MenuItem', N'Product Expire', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (547, 50, N'stockagingtoolStripMenuItem', N'MenuItem', N'Stock Aging', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (548, 50, N'gWPPWPTransactionToolStripMenuItem', N'MenuItem', N'GWP/PWP Transaction', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (549, 50, N'novelToolStripMenuItem', N'MenuItem', N'Novelties Sales', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (550, 50, N'toolsToolStripMenuItem', N'MenuItem', N'T&ools', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (551, 50, N'databaseExportToolStripMenuItem', N'MenuItem', N'&Backup Database', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (552, 50, N'databaseImportToolStripMenuItem', N'MenuItem', N'&Restore Database', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (553, 50, N'startDayToolStripMenuItem', N'MenuItem', N'Start Day', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (554, 50, N'endDayToolStripMenuItem', N'MenuItem', N'EndDay', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (555, 50, N'logInToolStripMenuItem1', N'MenuItem', N'&Log In', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (556, 50, N'logOutToolStripMenuItem', N'MenuItem', N'&Log Out', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (557, 50, N'helpToolStripMenuItem', N'MenuItem', N'Help', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (558, 51, N'dgvMemberList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (559, 51, N'label6', N'Label', N'%', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (560, 51, N'label4', N'Label', N'Member Card Discount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (561, 51, N'label7', N'Label', N'%', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (562, 51, N'label5', N'Label', N'Birthday Discount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (563, 51, N'rbtBetween', N'Radio', N'Between two amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (564, 51, N'rbtGreater', N'Radio', N'Greater than one amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (565, 51, N'lblTo', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (566, 51, N'label2', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (567, 51, N'label1', N'Label', N'Member Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (568, 51, N'groupBox3', N'GroupBox', N'Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (569, 51, N'groupBox2', N'GroupBox', N'Member Card Rule List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (570, 51, N'groupBox1', N'GroupBox', N'Add New Member Card Rule', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (571, 51, N'label13', N'Label', N'* Mandatory Fileds', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (572, 52, N'dgvMemberList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (573, 52, N'lblType', N'Label', N'Member Type  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (574, 52, N'groupBox2', N'GroupBox', N'Member Type List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (575, 52, N'groupBox1', N'GroupBox', N'Add New Memeber Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (576, 53, N'rdbFemale', N'Radio', N'Female', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (577, 53, N'rdbMale', N'Radio', N'Male', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (578, 53, N'label3', N'Label', N'Address', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (579, 53, N'label10', N'Label', N'Member Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (580, 53, N'label4', N'Label', N'NRIC', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (581, 53, N'label2', N'Label', N'Phone Number', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (582, 53, N'label1', N'Label', N'* Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (583, 53, N'label5', N'Label', N'Email', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (584, 53, N'label6', N'Label', N'Birthday', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (585, 53, N'label7', N'Label', N'Gender', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (586, 53, N'label8', N'Label', N'* City', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (587, 53, N'label9', N'Label', N'* Title', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (588, 53, N'label11', N'Label', N'Start to become Member at', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (589, 53, N'label12', N'Label', N'Member Id', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (590, 53, N'groupBox1', N'GroupBox', N'Add New Member', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (591, 53, N'label13', N'Label', N'* Mandatory Fileds', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (592, 54, N'label11', N'Label', N'Total Outstanding Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (593, 54, N'label5', N'Label', N'Total Outstanding Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (594, 54, N'lblTotalOutstanding', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (595, 54, N'lblAddress', N'Label', N'Address :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (596, 54, N'label4', N'Label', N'Address :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (597, 54, N'lblContactPerson', N'Label', N'Contact Person  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (598, 54, N'lblPhoneNumber', N'Label', N'Phone Number :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (599, 54, N'lblName', N'Label', N'Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (600, 54, N'lblEmail', N'Label', N'Email :', N'', N'', N'', N'', 1)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (601, 54, N'label1', N'Label', N'Supplier Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (602, 54, N'label9', N'Label', N'Email :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (603, 54, N'label2', N'Label', N'Phone Number :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (604, 54, N'label3', N'Label', N'Contact Person  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (605, 54, N'dgvOutstandingTransaction', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (606, 55, N'lblSupplierName', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (607, 55, N'lblsName', N'Label', N'Supplier Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (608, 55, N'groupBox1', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (609, 55, N'dgvSupplierList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (610, 56, N'label1', N'Label', N'Package Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (611, 56, N'lblSupplierName', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (612, 56, N'lblsName', N'Label', N'Customer Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (613, 56, N'groupBox2', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (614, 56, N'groupBox1', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (615, 56, N'dgvCustomerList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (616, 57, N'label10', N'Label', N':', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (617, 57, N'label9', N'Label', N':', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (618, 57, N'label8', N'Label', N':', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (619, 57, N'label7', N'Label', N':', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (620, 57, N'label5', N'Label', N'Total Stock Out Qty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (621, 57, N'label4', N'Label', N'Total Stock In Qty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (622, 57, N'label1', N'Label', N'Barcode', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (623, 57, N'label2', N'Label', N'Product Code', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (624, 57, N'label3', N'Label', N'Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (625, 57, N'lblBarcode', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (626, 57, N'lblSKU', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (627, 57, N'lblName', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (628, 57, N'lblTotalStockInQty', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (629, 57, N'lblTotalStockOutQty', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (630, 57, N'label6', N'Label', N':', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (631, 57, N'dgvQtyList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (632, 58, N'label1', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (633, 58, N'rdoCounterName', N'Radio', N'Counter Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (634, 58, N'rdoAll', N'Radio', N'All', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (635, 58, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (636, 58, N'rdoProduct', N'Radio', N'Product Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (637, 58, N'rdoBrand', N'Radio', N'Brand Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (638, 58, N'label3', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (639, 58, N'label2', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (640, 58, N'groupBox4', N'GroupBox', N'By Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (641, 58, N'groupBox1', N'GroupBox', N'Selecet One', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (642, 58, N'groupBox2', N'GroupBox', N'Gross Profit / Loss List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (643, 58, N'groupBox3', N'GroupBox', N'Selecet One', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (644, 58, N'gbPeriod', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (645, 59, N'dgvPurchaseDeleteLogPartial', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (646, 59, N'dgvPurchaseDeleteLog', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (647, 59, N'label3', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (648, 59, N'label2', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (649, 59, N'groupBox3', N'GroupBox', N'Partial Delete ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (650, 59, N'groupBox2', N'GroupBox', N'Whole Boucher Delete ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (651, 59, N'groupBox1', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (652, 60, N'dgvCounterList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (653, 60, N'label1', N'Label', N'Name  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (654, 60, N'groupBox2', N'GroupBox', N'Counter List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (655, 60, N'groupBox1', N'GroupBox', N'Add Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (656, 61, N'label4', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (657, 61, N'rdbDate', N'Radio', N'By Date', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (658, 61, N'rdbId', N'Radio', N'By Transaction Id', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (659, 61, N'label3', N'Label', N'Transaction Id', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (660, 61, N'label1', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (661, 61, N'label2', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (662, 61, N'groupBox1', N'GroupBox', N'By Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (663, 61, N'groupBox4', N'GroupBox', N'Search For Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (664, 61, N'gbId', N'GroupBox', N'By Transaction Id', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (665, 61, N'gbDate', N'GroupBox', N'By Date', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (666, 61, N'dgvTransactionList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (667, 62, N'label6', N'Label', N'Payable Amount:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (668, 62, N'lblPayableAmt', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (669, 62, N'label5', N'Label', N'Total Outstanding Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (670, 62, N'lblTotalOutstanding', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (671, 62, N'lblAddress', N'Label', N'Address :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (672, 62, N'label10', N'Label', N'Birthday :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (673, 62, N'lblBirthday', N'Label', N'Phone Number :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (674, 62, N'label11', N'Label', N'Gender :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (675, 62, N'lblGender', N'Label', N'NRC :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (676, 62, N'label4', N'Label', N'Address :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (677, 62, N'label12', N'Label', N'City :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (678, 62, N'lblCity', N'Label', N'Address :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (679, 62, N'dgvPrePaid', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (680, 62, N'dgvOutstandingTransaction', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (681, 62, N'groupBox1', N'GroupBox', N'Prepaid Debt List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (682, 62, N'dgvOldTransaction', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (683, 62, N'lblNrc', N'Label', N'NRC :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (684, 62, N'lblPhoneNumber', N'Label', N'Phone Number :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (685, 62, N'lblName', N'Label', N'Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (686, 62, N'lblEmail', N'Label', N'Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (687, 62, N'label1', N'Label', N'Customer Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (688, 62, N'label9', N'Label', N'Email :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (689, 62, N'label2', N'Label', N'Phone Number :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (690, 62, N'label3', N'Label', N'NRC :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (691, 63, N'lblBirthday', N'Label', N'Bithday :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (692, 63, N'label4', N'Label', N'Address :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (693, 63, N'label10', N'Label', N'Birthday :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (694, 63, N'lblAddress', N'Label', N'Address :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (695, 63, N'label12', N'Label', N'City :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (696, 63, N'lblCity', N'Label', N'City :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (697, 63, N'label9', N'Label', N'Email :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (698, 63, N'lblEmail', N'Label', N'Email :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (699, 63, N'label2', N'Label', N'Phone Number :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (700, 63, N'lblPhoneNumber', N'Label', N'Phone Number :', N'', N'', N'', N'', 1)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (701, 63, N'lblMType', N'Label', N'Member Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (702, 63, N'lblMCId', N'Label', N'Member Card Id', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (703, 63, N'lblName', N'Label', N'Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (704, 63, N'lblGender', N'Label', N'Gender :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (705, 63, N'label1', N'Label', N'Customer Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (706, 63, N'label11', N'Label', N'Gender :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (707, 63, N'label3', N'Label', N'NRC :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (708, 63, N'lblNrc', N'Label', N'NRC :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (709, 63, N'label5', N'Label', N'Member Card Id', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (710, 63, N'label6', N'Label', N'Member Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (711, 63, N'lbltamtspentholder', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (712, 63, N'lbltamtspent', N'Label', N'Total Amount Spent :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (713, 63, N'dgvNormalTransaction', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (714, 64, N'dgvCustomerList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (715, 64, N'label10', N'Label', N'Member Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (716, 64, N'rdoBirthday', N'Radio', N'Birthday', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (717, 64, N'lblSearchTitle', N'Label', N'Member Card No.', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (718, 64, N'rdoMemberCardNo', N'Radio', N'Member Card No.', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (719, 64, N'rdoCustomerName', N'Radio', N'Customer Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (720, 64, N'groupBox3', N'GroupBox', N'Customer List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (721, 64, N'groupBox2', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (722, 64, N'groupBox1', N'GroupBox', N'Search By', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (723, 65, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (724, 65, N'label6', N'Label', N'Counter Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (725, 65, N'label3', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (726, 65, N'label2', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (727, 65, N'groupBox1', N'GroupBox', N'Product Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (728, 65, N'gbPeriod', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (729, 66, N'label1', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (730, 66, N'dgvDeleteLogPartial', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (731, 66, N'dgvDeleteLog', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (732, 66, N'label3', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (733, 66, N'label2', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (734, 66, N'groupBox4', N'GroupBox', N'By Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (735, 66, N'groupBox3', N'GroupBox', N'Partial Delete ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (736, 66, N'groupBox2', N'GroupBox', N'Whole Boucher Delete ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (737, 66, N'groupBox1', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (738, 67, N'lblTime', N'Label', N'hr:mm', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (739, 67, N'label5', N'Label', N'Time :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (740, 67, N'lblDate', N'Label', N'dd-mm-yyyy', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (741, 67, N'label3', N'Label', N'Date :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (742, 67, N'lblSalesPersonName', N'Label', N'Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (743, 67, N'label1', N'Label', N'Sale Person :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (744, 67, N'dgvSalesItem', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (745, 68, N'dgvDraftList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (746, 68, N'label2', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (747, 68, N'label1', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (748, 69, N'label1', N'Label', N'10,000', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (749, 69, N'label2', N'Label', N'500', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (750, 69, N'label3', N'Label', N'50', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (751, 69, N'label4', N'Label', N'5,000', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (752, 69, N'label5', N'Label', N'200', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (753, 69, N'label6', N'Label', N'20', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (754, 69, N'label9', N'Label', N'10', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (755, 69, N'label8', N'Label', N'100', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (756, 69, N'label7', N'Label', N'1,000', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (757, 69, N'lblOpeningBalance', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (758, 69, N'label10', N'Label', N'Total', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (759, 69, N'label18', N'Label', N'Opening Balance', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (760, 69, N'lblTotal', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (761, 69, N'label16', N'Label', N'Comment', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (762, 69, N'label13', N'Label', N'Other Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (763, 69, N'lblRequireAmount', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (764, 69, N'lblRequireOrOver', N'Label', N'Required Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (765, 69, N'label12', N'Label', N'Total Income', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (766, 69, N'lblTotalIncome', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (767, 70, N'label10', N'Label', N'Member Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (768, 70, N'rdoBirthday', N'Radio', N'Birthday', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (769, 70, N'lblSearchTitle', N'Label', N'Member Card No.', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (770, 70, N'rdoMemberCardNo', N'Radio', N'Member Card No.', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (771, 70, N'rdoCustomerName', N'Radio', N'Customer Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (772, 70, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (773, 70, N'groupBox3', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (774, 70, N'groupBox1', N'GroupBox', N'Search By', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (775, 70, N'groupBox2', N'GroupBox', N'Customer List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (776, 71, N'label5', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (777, 71, N'label2', N'Label', N'To :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (778, 71, N'label1', N'Label', N'From :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (779, 71, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (780, 71, N'label4', N'Label', N'Product Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (781, 71, N'label3', N'Label', N'Customer Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (782, 71, N'groupBox1', N'GroupBox', N'By Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (783, 71, N'groupBox2', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (784, 71, N'gbList', N'GroupBox', N'Customer''s  Sale Product List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (785, 71, N'groupBox3', N'GroupBox', N'By Name:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (786, 72, N'label3', N'Label', N'Card No :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (787, 72, N'dgvGiftCardList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (788, 72, N'label1', N'Label', N'Card No :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (789, 72, N'label2', N'Label', N'Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (790, 72, N'groupBox3', N'GroupBox', N'Search', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (791, 72, N'groupBox2', N'GroupBox', N'Gift Card List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (792, 72, N'groupBox1', N'GroupBox', N'Add Gift Card', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (793, 73, N'rdAll', N'Radio', N'All', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (794, 73, N'rdNonConsignment', N'Radio', N'Non-Consignment Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (795, 73, N'rdConsignment', N'Radio', N'Consignment Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (796, 73, N'label2', N'Label', N'Category :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (797, 73, N'label1', N'Label', N'Barcode :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (798, 73, N'label3', N'Label', N'Sub Category :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (799, 73, N'label4', N'Label', N'Brand :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (800, 73, N'label5', N'Label', N'Name :', N'', N'', N'', N'', 1)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (801, 73, N'groupBox2', N'GroupBox', N'Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (802, 73, N'groupBox1', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (803, 73, N'dgvItemList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (804, 74, N'label1', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (805, 74, N'label9', N'Label', N'&Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (806, 74, N'label3', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (807, 74, N'label2', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (808, 74, N'rdoFOC', N'Radio', N'FOC', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (809, 74, N'rdbRefund', N'Radio', N'Refund', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (810, 74, N'rdbSale', N'Radio', N'Sale', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (811, 74, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (812, 74, N'groupBox4', N'GroupBox', N'By Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (813, 74, N'groupBox3', N'GroupBox', N'By Product Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (814, 74, N'groupBox1', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (815, 74, N'groupBox2', N'GroupBox', N'By Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (816, 74, N'gbList', N'GroupBox', N'Item Sale Report', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (817, 75, N'label1', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (818, 75, N'label3', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (819, 75, N'label2', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (820, 75, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (821, 75, N'groupBox2', N'GroupBox', N'By Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (822, 75, N'groupBox1', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (823, 75, N'gbList', N'GroupBox', N'Daily Sales Report', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (824, 76, N'lblUser', N'Label', N'User Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (825, 76, N'lblCounter', N'Label', N'Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (826, 76, N'lblPassword', N'Label', N'Password', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (827, 77, N'rdbFemale', N'Radio', N'Female', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (828, 77, N'rdbMale', N'Radio', N'Male', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (829, 77, N'label4', N'Label', N'NRIC', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (830, 77, N'label2', N'Label', N'Phone Number', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (831, 77, N'label5', N'Label', N'* Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (832, 77, N'label6', N'Label', N'Email', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (833, 77, N'label7', N'Label', N'Birthday', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (834, 77, N'label8', N'Label', N'Gender', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (835, 77, N'label9', N'Label', N'* City', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (836, 77, N'label14', N'Label', N'* Title', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (837, 77, N'label3', N'Label', N'Address', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (838, 77, N'label10', N'Label', N'Member Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (839, 77, N'label11', N'Label', N'Start to become Member at', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (840, 77, N'label12', N'Label', N'Member Id', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (841, 77, N'groupBox2', N'GroupBox', N'Customer Information', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (842, 77, N'groupBox1', N'GroupBox', N'Member Card Information', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (843, 77, N'label13', N'Label', N'* Mandatory Fileds', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (844, 78, N'label26', N'Label', N'Use Reference', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (845, 78, N'lblReferenceProductName', N'Label', N'Reference Product Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (846, 78, N'chkUseReference', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (847, 78, N'label21', N'Label', N'Special Promotion ?', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (848, 78, N'chkSpecialPromotion', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (849, 78, N'label23', N'Label', N'*', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (850, 78, N'rdoAmount', N'Radio', N'Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (851, 78, N'rdoPercent', N'Radio', N'Percent(%)', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (852, 78, N'label22', N'Label', N'Total Consignment Qty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (853, 78, N'label12', N'Label', N'Is Consignment Item?', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (854, 78, N'label13', N'Label', N'* Consignor', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (855, 78, N'chkIsConsignment', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (856, 78, N'label14', N'Label', N'Consignment Price', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (857, 78, N'label9', N'Label', N'Consignment Qty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (858, 78, N'label25', N'Label', N'Stock Unit', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (859, 78, N'label24', N'Label', N'Whole Sale Price', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (860, 78, N'label2', N'Label', N'* Brand', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (861, 78, N'label20', N'Label', N'* Barcode', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (862, 78, N'label18', N'Label', N'Size', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (863, 78, N'Label17', N'Label', N'Purchase Price', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (864, 78, N'label15', N'Label', N'Location', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (865, 78, N'label11', N'Label', N'* Unit', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (866, 78, N'label10', N'Label', N'Min Stock Qty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (867, 78, N'lblQty', N'Label', N'Qty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (868, 78, N'label19', N'Label', N'Is Minimum Stock', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (869, 78, N'label8', N'Label', N'Discount Percent', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (870, 78, N'label16', N'Label', N'Tax Percent', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (871, 78, N'label7', N'Label', N'Sub Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (872, 78, N'label6', N'Label', N'* Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (873, 78, N'label3', N'Label', N'* Product Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (874, 78, N'label1', N'Label', N'* Product Code', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (875, 78, N'label4', N'Label', N'* Unit Price', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (876, 78, N'chkMinStock', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (877, 78, N'label27', N'Label', N'*  Mandatory  Fileds', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (878, 78, N'label5', N'Label', N'Photo :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (879, 78, N'dgvChildItems', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (880, 79, N'label2', N'Label', N'* Phone Number :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (881, 79, N'label3', N'Label', N'  Email : ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (882, 79, N'label4', N'Label', N'* Address', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (883, 79, N'label5', N'Label', N'* Contact Person', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (884, 79, N'label1', N'Label', N'* Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (885, 79, N'label13', N'Label', N'* Mandatory Fileds', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (886, 80, N'rdoBoth', N'Radio', N'Both', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (887, 80, N'rdoPOS', N'Radio', N'POS', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (888, 80, N'rdoBackOffice', N'Radio', N'BackOffice', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (889, 80, N'label4', N'Label', N'Confirm Password', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (890, 80, N'label1', N'Label', N'Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (891, 80, N'label2', N'Label', N'Password', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (892, 80, N'label5', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (893, 80, N'label3', N'Label', N'User Role', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (894, 80, N'groupBox1', N'GroupBox', N'Menu Permission', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (895, 81, N'lblSupplierName', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (896, 81, N'lblsName', N'Label', N'Customer Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (897, 81, N'groupBox1', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (898, 81, N'dgvCustomerList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (899, 82, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (900, 82, N'label1', N'Label', N'Customer Name :', N'', N'', N'', N'', 1)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (901, 82, N'groupBox2', N'GroupBox', N'Outstanding Report', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (902, 82, N'groupBox1', N'GroupBox', N'Search By Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (903, 83, N'label3', N'Label', N'C&urrency', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (904, 83, N'label1', N'Label', N'&Receive Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (905, 83, N'label2', N'Label', N'Total Cost', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (906, 83, N'lblChangesText', N'Label', N'Changes', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (907, 83, N'lblTotalCost', N'Label', N'0000', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (908, 83, N'lblChanges', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (909, 84, N'lblPreviousBalance', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (910, 84, N'label4', N'Label', N'Customer &Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (911, 84, N'label5', N'Label', N'Previous Balance', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (912, 84, N'lblNetPayableTitle', N'Label', N'Net Payable', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (913, 84, N'lblNetPayable', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (914, 84, N'label2', N'Label', N'Total Cost', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (915, 84, N'lblTotalCost', N'Label', N'0000', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (916, 84, N'label1', N'Label', N'&Receive Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (917, 84, N'Label6', N'Label', N'Current Cost', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (918, 84, N'lblAccuralCost', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (919, 84, N'label3', N'Label', N'Prepaid Balance', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (920, 84, N'label7', N'Label', N'Is Use Prepaid Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (921, 84, N'chkIsPrePaid', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (922, 84, N'lblPrePaid', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (923, 86, N'label5', N'Label', N'Changes', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (924, 86, N'lblChangesText', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (925, 86, N'lblPayableAmount', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (926, 86, N'label7', N'Label', N'Payable Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (927, 86, N'lblTotalCost', N'Label', N'0000', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (928, 86, N'label2', N'Label', N'Total Cost', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (929, 86, N'label4', N'Label', N'Cash', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (930, 86, N'lblAmountFromGiftCard', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (931, 86, N'label6', N'Label', N'Amount from GiftCards', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (932, 86, N'label1', N'Label', N'&Gift Card Id', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (933, 88, N'label5', N'Label', N'Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (934, 88, N'label4', N'Label', N'Brand :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (935, 88, N'label3', N'Label', N'Sub Category :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (936, 88, N'label2', N'Label', N'Category :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (937, 88, N'dgvItemList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (938, 89, N'label2', N'Label', N'Product Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (939, 89, N'label1', N'Label', N'Barcode :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (940, 89, N'label3', N'Label', N'1 X 3  =3', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (941, 89, N'label4', N'Label', N'Number of Row :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (942, 89, N'lblBarCode', N'Label', N'lblBarCode', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (943, 89, N'lblItemName', N'Label', N'lblItemName', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (944, 89, N'groupBox1', N'GroupBox', N'Preview', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (945, 90, N'dgvProductCList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (946, 90, N'label1', N'Label', N'Name  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (947, 90, N'groupBox2', N'GroupBox', N'Product Category List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (948, 90, N'groupBox1', N'GroupBox', N'Add New Product Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (949, 91, N'lblName', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (950, 91, N'lblSKU', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (951, 91, N'lblBarcode', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (952, 91, N'label1', N'Label', N'Barcode', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (953, 91, N'label2', N'Label', N'Product Code', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (954, 91, N'label3', N'Label', N'Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (955, 91, N'dgvPriceList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (956, 92, N'rbtNonConsignment', N'Radio', N'Non-Consignment Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (957, 92, N'rbtConsignment', N'Radio', N'Consignment Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (958, 92, N'label5', N'Label', N'Brand', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (959, 92, N'label6', N'Label', N'Product Code', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (960, 92, N'label4', N'Label', N'Sub-Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (961, 92, N'label3', N'Label', N'Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (962, 92, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (963, 92, N'groupBox2', N'GroupBox', N'Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (964, 92, N'groupBox4', N'GroupBox', N'By Brand', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (965, 92, N'groupBox5', N'GroupBox', N'By Product Code', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (966, 92, N'groupBox3', N'GroupBox', N'By Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (967, 92, N'lblCurrentDate', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (968, 92, N'label1', N'Label', N'Date:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (969, 92, N'groupBox1', N'GroupBox', N'Product List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (970, 93, N'dgvProductList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (971, 93, N'label1', N'Label', N'Sub Category Name  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (972, 93, N'label2', N'Label', N'Main Category :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (973, 93, N'label3', N'Label', N'Sub Category Code :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (974, 93, N'groupBox2', N'GroupBox', N'Sub Category List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (975, 93, N'groupBox1', N'GroupBox', N'Add New Product SubCategory', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (976, 94, N'label7', N'Label', N'Discount Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (977, 94, N'lblDiscount', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (978, 94, N'lblSettlement', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (979, 94, N'lblOldCredit', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (980, 94, N'lblcash', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (981, 94, N'lblTotalAmount', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (982, 94, N'label5', N'Label', N'Settlement Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (983, 94, N'label8', N'Label', N'Credit Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (984, 94, N'label6', N'Label', N'Cash :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (985, 94, N'label4', N'Label', N'Total Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (986, 94, N'label9', N'Label', N'Total Quantity :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (987, 94, N'lblTotalQty', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (988, 94, N'dgvProductList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (989, 94, N'label1', N'Label', N'Supplier Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (990, 94, N'label2', N'Label', N'Voucher No :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (991, 94, N'lblSupplerName', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (992, 94, N'lblVoucherNo', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (993, 94, N'label3', N'Label', N'Date :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (994, 94, N'lblDate', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (995, 94, N'groupBox1', N'GroupBox', N'Purchase Product List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (996, 95, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (997, 95, N'label1', N'Label', N'Supplier Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (998, 95, N'label3', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (999, 95, N'label2', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1000, 95, N'groupBox2', N'GroupBox', N'Purchase Discount List', N'', N'', N'', N'', 1)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1001, 95, N'groupBox3', N'GroupBox', N'By Supplier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1002, 95, N'gbPeriod', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1003, 96, N'label2', N'Label', N'* Voucher No :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1004, 96, N'label3', N'Label', N'* Supplier :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1005, 96, N'label1', N'Label', N'Date :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1006, 96, N'label7', N'Label', N'*Other Invoice Outstanding Balance :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1007, 96, N'label10', N'Label', N'Discount Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1008, 96, N'label9', N'Label', N'* Paid :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1009, 96, N'label8', N'Label', N'Total Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1010, 96, N'label12', N'Label', N'Total Payable Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1011, 96, N'label11', N'Label', N'Credit Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1012, 96, N'label14', N'Label', N'* Barcode :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1013, 96, N'label4', N'Label', N'* Product Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1014, 96, N'label15', N'Label', N'* Expire Date :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1015, 96, N'label6', N'Label', N'* Unit Price :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1016, 96, N'label5', N'Label', N'* Qty :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1017, 96, N'dgvProductList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1018, 96, N'groupBox2', N'GroupBox', N'Purchase Vouncher', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1019, 96, N'label13', N'Label', N'* Mandatory Fileds', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1020, 96, N'groupBox1', N'GroupBox', N'Add Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1021, 97, N'label3', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1022, 97, N'label4', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1023, 97, N'rdoApproved', N'Radio', N'Approved', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1024, 97, N'rdoPending', N'Radio', N'Pending', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1025, 97, N'txtOutstandingCreditAmt', N'Label', N'Outstanding Credit Amount:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1026, 97, N'label2', N'Label', N'Outstanding Credit Amount    :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1027, 97, N'lblSupplierName', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1028, 97, N'lblsName', N'Label', N'Supplier Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1029, 97, N'dgvMainPurchaseList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1030, 97, N'groupBox4', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1031, 97, N'groupBox3', N'GroupBox', N'By Status', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1032, 97, N'groupBox2', N'GroupBox', N'By Supplier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1033, 97, N'groupBox1', N'GroupBox', N'Purchase List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1034, 98, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1035, 98, N'label3', N'Label', N'Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1036, 98, N'label1', N'Label', N'Main Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1037, 98, N'label2', N'Label', N'Sub Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1038, 98, N'gbTitle', N'GroupBox', N'Reorder Point', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1039, 98, N'groupBox2', N'GroupBox', N'By Brand', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1040, 98, N'groupBox1', N'GroupBox', N'By Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1041, 99, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1042, 99, N'rdoBrandName', N'Radio', N'Brand Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1043, 99, N'rdoProductName', N'Radio', N'Product Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1044, 99, N'rdoSupplierName', N'Radio', N'Supplier Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1045, 99, N'label3', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1046, 99, N'label2', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1047, 99, N'groupBox2', N'GroupBox', N'Purchase List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1048, 99, N'groupBox3', N'GroupBox', N'Selecet One', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1049, 99, N'gbPeriod', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1050, 100, N'label4', N'Label', N'Total :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1051, 100, N'lblTotal', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1052, 100, N'lblCash', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1053, 100, N'label5', N'Label', N'Discount Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1054, 100, N'label6', N'Label', N'Total Refund Amount : (Including Discount)', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1055, 100, N'lblChangeGiven', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1056, 100, N'lblMainTransaction', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1057, 100, N'label7', N'Label', N'Main Transaction :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1058, 100, N'lblDate', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1059, 100, N'lblSalePerson', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1060, 100, N'lblTime', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1061, 100, N'dgvRefundDetail', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1062, 100, N'label3', N'Label', N'Time :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1063, 100, N'label2', N'Label', N'Date :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1064, 100, N'label1', N'Label', N'Sale Person :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1065, 101, N'label1', N'Label', N'We take discount amount from refund amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1066, 102, N'label3', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1067, 102, N'label1', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1068, 102, N'label2', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1069, 102, N'groupBox2', N'GroupBox', N'By Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1070, 102, N'groupBox1', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1071, 102, N'dgvRefundList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1072, 103, N'dgvItemLists', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1073, 103, N'dgvRedundedList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1074, 103, N'lblRefund', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1075, 103, N'lblTotalREfundAmount', N'Label', N'Total Refund Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1076, 103, N'label4', N'Label', N'Vouncher Discount  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1077, 103, N'lblDiscount', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1078, 103, N'lblChangeGivenTitle', N'Label', N'Change Given :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1079, 103, N'lblChangeGiven', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1080, 103, N'lblCash', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1081, 103, N'label8', N'Label', N'Received  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1082, 103, N'label10', N'Label', N'Total : ( Including Discount)', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1083, 103, N'lblTotal', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1084, 103, N'label5', N'Label', N'Member Card Discount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1085, 103, N'lblMemberCardDiscount', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1086, 103, N'groupBox2', N'GroupBox', N'To Refund ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1087, 103, N'groupBox1', N'GroupBox', N'Refunded List Of Current Transaction', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1088, 103, N'lblMainTransaction', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1089, 103, N'label7', N'Label', N'Main Transaction :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1090, 103, N'lblTime', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1091, 103, N'lblDate', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1092, 103, N'lblSalePerson', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1093, 103, N'label3', N'Label', N'Time :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1094, 103, N'label2', N'Label', N'Date :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1095, 103, N'label1', N'Label', N'Sale Person :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1096, 104, N'label1', N'Label', N'License Key', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1097, 104, N'lblMainText', N'Label', N'Please enter the License key in order to use this application. If you don''t have one, please contact to admin@sourcecode.com.sg.', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1098, 105, N'chkEditTaxRateC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1099, 105, N'chkAddTaxRateC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1100, 105, N'chkEditTaxRateSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1101, 105, N'chkAddTaxRateSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1102, 105, N'label167', N'Label', N'Edit/Delete Tax Rate', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1103, 105, N'label163', N'Label', N'Add New Tax Rate', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1104, 105, N'label5', N'Label', N'Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1105, 105, N'label138', N'Label', N'Super Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1106, 105, N'label19', N'Label', N'Edit/Delete Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1107, 105, N'chkAddCounterC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1108, 105, N'chkEditCounterSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1109, 105, N'label139', N'Label', N'Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1110, 105, N'label162', N'Label', N'Tax Rate', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1111, 105, N'chkAddCounterSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1112, 105, N'chkEditMeasurementUnitC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1113, 105, N'chkEditMeasurementUnitSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1114, 105, N'chkAddMeasurementUnitSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1115, 105, N'chkAddMeasurementUnitC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1116, 105, N'label160', N'Label', N'Edit/Delete Measurement Unit', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1117, 105, N'label158', N'Label', N'Add New Measurement Unit', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1118, 105, N'label157', N'Label', N'Measurement Unit', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1119, 105, N'chkEditCounterC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1120, 105, N'label20', N'Label', N'Add New Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1121, 105, N'label28', N'Label', N'Consignor', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1122, 105, N'label59', N'Label', N'Add New Consignor', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1123, 105, N'label87', N'Label', N'Edit/Delete Consignror', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1124, 105, N'chkAddConsignorSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1125, 105, N'chkAddConsignorC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1126, 105, N'chkEditConsignorC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1127, 105, N'chkEditConsignorSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1128, 105, N'label113', N'Label', N'Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1129, 105, N'label26', N'Label', N'Super Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1130, 105, N'label4', N'Label', N'Brand', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1131, 105, N'label12', N'Label', N'View Brand List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1132, 105, N'label10', N'Label', N'Edit/Delete Brand', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1133, 105, N'label6', N'Label', N'Add New Brand', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1134, 105, N'chkViewBrandSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1135, 105, N'chkEditBrandSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1136, 105, N'chkAddBrandSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1137, 105, N'chkViewBrandC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1138, 105, N'chkEditBrandC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1139, 105, N'chkAddBrandC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1140, 105, N'label15', N'Label', N'Main Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1141, 105, N'label24', N'Label', N'View Category List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1142, 105, N'label13', N'Label', N'Edit/Delete Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1143, 105, N'label14', N'Label', N'Add New Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1144, 105, N'chkViewCategorySC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1145, 105, N'chkEditCategorySC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1146, 105, N'chkAddCategorySC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1147, 105, N'chkViewCategoryC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1148, 105, N'chkEditCategoryC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1149, 105, N'chkAddCategoryC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1150, 105, N'label18', N'Label', N'Sub Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1151, 105, N'label23', N'Label', N'View Sub Category List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1152, 105, N'label16', N'Label', N'Edit/Delete Sub Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1153, 105, N'label17', N'Label', N'Add New Sub Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1154, 105, N'chkViewSubCategorySC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1155, 105, N'chkEditSubCategorySC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1156, 105, N'chkAddSubCategorySC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1157, 105, N'chkViewSubCategoryC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1158, 105, N'chkEditCityC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1159, 105, N'chkAddCityC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1160, 105, N'chkEditCitySC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1161, 105, N'chkAddCitySC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1162, 105, N'label136', N'Label', N'Edit/Delete City', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1163, 105, N'label86', N'Label', N'Add New City', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1164, 105, N'lblCity', N'Label', N'City', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1165, 105, N'chkEditSubCategoryC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1166, 105, N'chkAddSubCategoryC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1167, 105, N'label115', N'Label', N'Stock Unit Conversion', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1168, 105, N'label116', N'Label', N'View Stock Unit Conversion List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1169, 105, N'label117', N'Label', N'Add New Stock Unit Conversion', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1170, 105, N'chkViewUConversionSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1171, 105, N'chkAddUConversionSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1172, 105, N'chkViewUConversionC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1173, 105, N'chkAddUConversionC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1174, 105, N'chkSelectAllBOC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1175, 105, N'chkSelectAllBOSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1176, 105, N'label131', N'Label', N'Back Office -> Select All >', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1177, 105, N'chkAddNewAdjustmentSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1178, 105, N'chkEditDeleteAdjustmentSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1179, 105, N'chkEditDeleteAdjustmentC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1180, 105, N'chkViewAdjustmentSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1181, 105, N'label73', N'Label', N'Add New Adjustment', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1182, 105, N'chkViewAdjustmentC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1183, 105, N'label72', N'Label', N'Edit/Delete Adjustment', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1184, 105, N'label71', N'Label', N'View Adjustment List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1185, 105, N'label70', N'Label', N'Adjustment', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1186, 105, N'chkApprovedPurC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1187, 105, N'label50', N'Label', N'View Purchase List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1188, 105, N'chkApprovedPurSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1189, 105, N'chkDeleteLogPurC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1190, 105, N'label122', N'Label', N'Approved Purchase', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1191, 105, N'label44', N'Label', N'Add New Purchase', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1192, 105, N'label7', N'Label', N'Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1193, 105, N'chkAddPurchase_C', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1194, 105, N'label1', N'Label', N'Super Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1195, 105, N'label121', N'Label', N'View Delete Log Purchase', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1196, 105, N'label51', N'Label', N'Edit/Delete Purchase', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1197, 105, N'chkAddPurchase_SC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1198, 105, N'label58', N'Label', N'View Purchase Detail', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1199, 105, N'label32', N'Label', N'Supplier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1200, 105, N'label37', N'Label', N'View Supplier List', N'', N'', N'', N'', 1)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1201, 105, N'label48', N'Label', N'Edit/Delete Supplier ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1202, 105, N'chkPurcaseDetail_C', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1203, 105, N'label61', N'Label', N'View Detail Voucher', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1204, 105, N'label49', N'Label', N'Add Supplier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1205, 105, N'chkPurchaseDetail_SC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1206, 105, N'chkPurchaseDetelte_SC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1207, 105, N'label120', N'Label', N'View Outstanding Supplier List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1208, 105, N'label119', N'Label', N'View Outstanding Supplier Detail', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1209, 105, N'chkPurchaseDetelte_C', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1210, 105, N'chkViewSupplierSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1211, 105, N'chkEditSupplierSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1212, 105, N'chkPurchaseListC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1213, 105, N'chk_ViewDetailVoucher_SC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1214, 105, N'chkAddSupplierSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1215, 105, N'chkOutstandingSupListSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1216, 105, N'chkOutstandingSupDetailSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1217, 105, N'chkPurchaseListSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1218, 105, N'chkViewSupplierC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1219, 105, N'chkEditSupplierC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1220, 105, N'chk_ViewDetailVoucher_C', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1221, 105, N'chkAddSupplierC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1222, 105, N'chkOutstandingSupListC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1223, 105, N'chkOutstandingSupDetailC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1224, 105, N'label52', N'Label', N'Purchasing', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1225, 105, N'chkDeleteLogPurSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1226, 105, N'chkAddNewAdjustmentC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1227, 105, N'chkEditDeleteExpCagC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1228, 105, N'label25', N'Label', N'Super Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1229, 105, N'chkAddNewExpCagC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1230, 105, N'label152', N'Label', N'Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1231, 105, N'chkEditDeleteExpCagSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1232, 105, N'chkAddNewExpCagSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1233, 105, N'label144', N'Label', N'Edit/Delete Expense Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1234, 105, N'chkDeleteLogExpenseSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1235, 105, N'chkAddExpense_SC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1236, 105, N'label145', N'Label', N'Add New Expense Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1237, 105, N'chkExpenseDetail_SC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1238, 105, N'label147', N'Label', N'Expense Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1239, 105, N'chkExpenseDetelte_SC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1240, 105, N'chkExpenseListSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1241, 105, N'chkDeleteLogExpenseC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1242, 105, N'chkAddExpense_C', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1243, 105, N'chkExpenseDetail_C', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1244, 105, N'chkExpenseDetelte_C', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1245, 105, N'chkExpenseListC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1246, 105, N'label140', N'Label', N'View Delete Log Expense', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1247, 105, N'label137', N'Label', N'Add New Expense', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1248, 105, N'label114', N'Label', N'View Expense Detail', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1249, 105, N'label112', N'Label', N'Edit/Delete Expense', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1250, 105, N'label100', N'Label', N'View Expense List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1251, 105, N'label146', N'Label', N'Expense', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1252, 105, N'label143', N'Label', N'Approved Expense', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1253, 105, N'chkApprovedExpenseSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1254, 105, N'chkApprovedExpenseC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1255, 105, N'label125', N'Label', N'Stock Management', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1256, 105, N'label126', N'Label', N'View Stock Transaction List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1257, 105, N'label129', N'Label', N'Approved Stock Transaction', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1258, 105, N'chkViewStockTransListSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1259, 105, N'chkViewStockTransListC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1260, 105, N'chkApproveStockTransactionSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1261, 105, N'chkApproveStockTransactionC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1262, 105, N'chkStockInOutReturnC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1263, 105, N'label128', N'Label', N'Add Stock In/Out/Return', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1264, 105, N'label132', N'Label', N'Edit/Delete Stock Transaction', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1265, 105, N'chkEditDeleteStockTranscationSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1266, 105, N'chkEditDeleteStockTranscationC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1267, 105, N'chkStockInOutReturnSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1268, 105, N'label133', N'Label', N'Promotion ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1269, 105, N'label134', N'Label', N'View Promotion List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1270, 105, N'label135', N'Label', N'Edit/Delete Promotion ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1271, 105, N'label141', N'Label', N'Novelty System', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1272, 105, N'label148', N'Label', N'Add New Promotion', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1273, 105, N'label142', N'Label', N'View Novelty List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1274, 105, N'label156', N'Label', N'Edit/Delete Novelty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1275, 105, N'label169', N'Label', N'Add New Novelty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1276, 105, N'chkViewPromotionSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1277, 105, N'chkEditPromotionSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1278, 105, N'chkAddPromotionSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1279, 105, N'chkEditPromotionC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1280, 105, N'chkAddPromotionC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1281, 105, N'chkViewPromotionC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1282, 105, N'chkViewNoveltySC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1283, 105, N'chkAddNoveltySC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1284, 105, N'chkEditNoveltySC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1285, 105, N'chkViewNoveltyC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1286, 105, N'chkAddNoveltyC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1287, 105, N'chkEditNoveltyC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1288, 105, N'chkSelectAllBOPOSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1289, 105, N'chkSelectAllBOPOSSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1290, 105, N'label27', N'Label', N'Back Office And POS -> Select All >', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1291, 105, N'chkOutstandingCusDetailC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1292, 105, N'chkOutstandingCusDetailSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1293, 105, N'chkOutstandingCusListC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1294, 105, N'chkOutstandingCusListSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1295, 105, N'chkAddCustomerC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1296, 105, N'chkAddCustomerSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1297, 105, N'chk_customerViewDetail_C', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1298, 105, N'chk_customerViewDetail_SC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1299, 105, N'chkEditCustomerC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1300, 105, N'chkEditCustomerSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1301, 105, N'label159', N'Label', N'View Outstanding Customer Detail', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1302, 105, N'label161', N'Label', N'View Outstanding Customer List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1303, 105, N'label170', N'Label', N'Add Customer', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1304, 105, N'label168', N'Label', N'View Detail', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1305, 105, N'label166', N'Label', N'Edit/Delete Customer', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1306, 105, N'chkViewCustomerC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1307, 105, N'chkViewCustomerSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1308, 105, N'label165', N'Label', N'View Customer List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1309, 105, N'label164', N'Label', N'Customer', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1310, 105, N'label154', N'Label', N'Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1311, 105, N'label155', N'Label', N'Super Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1312, 105, N'label80', N'Label', N'Delete Refund', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1313, 105, N'label77', N'Label', N'Refund', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1314, 105, N'chkDeleteRefundSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1315, 105, N'chkDeleteRefundC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1316, 105, N'label85', N'Label', N'Delete Transaction Detail', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1317, 105, N'label84', N'Label', N'Transaction Detail', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1318, 105, N'chkDeleteTransactionDetailSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1319, 105, N'chkDeleteTransactionDetailC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1320, 105, N'label82', N'Label', N'Delete&&Copy Credit Transaction', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1321, 105, N'label83', N'Label', N'Delete Credit Transaction', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1322, 105, N'label81', N'Label', N'Credit Transaction ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1323, 105, N'chkDeleteAndCopyCreditTransactionSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1324, 105, N'chkDeleteAndCopyCreditTransactionC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1325, 105, N'chkDeleteCreditTransactionSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1326, 105, N'chkDeleteCreditTransactionC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1327, 105, N'label78', N'Label', N'Delete&&Copy Transaction', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1328, 105, N'label79', N'Label', N'Delete Transaction', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1329, 105, N'label76', N'Label', N'Transaction', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1330, 105, N'chkDeleteAndCopyTransactionSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1331, 105, N'chkDeleteAndCopyTransactionC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1332, 105, N'chkDeleteTransactionC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1333, 105, N'chkDeleteTransactionSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1334, 105, N'chkDeleteConsignmentSettlementC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1335, 105, N'chkDeleteConsignmentSettlementSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1336, 105, N'label90', N'Label', N'Delete Consignment Settlement', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1337, 105, N'chkViewConsignmentSettlementC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1338, 105, N'chkViewConsignmentSettlementSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1339, 105, N'label89', N'Label', N'View Consignment Settlement', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1340, 105, N'chkDeleteGiftCardC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1341, 105, N'chkDeleteGiftCardSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1342, 105, N'chkAddGiftcardC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1343, 105, N'label8', N'Label', N'Register Giftcard', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1344, 105, N'chkAddProductSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1345, 105, N'label2', N'Label', N'Add New Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1346, 105, N'chkEditProductC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1347, 105, N'chkViewProductC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1348, 105, N'chkSettingC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1349, 105, N'label151', N'Label', N'Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1350, 105, N'label153', N'Label', N'Super Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1351, 105, N'label130', N'Label', N'Currency Exchange', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1352, 105, N'label109', N'Label', N'Setting', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1353, 105, N'label123', N'Label', N'Configuration (Settings)', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1354, 105, N'chkSettingSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1355, 105, N'label127', N'Label', N'Add New Currency Exchange', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1356, 105, N'chkAddCurrencyExchangeSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1357, 105, N'chkAddCurrencyExchangeC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1358, 105, N'label88', N'Label', N'Consignment Settlement', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1359, 105, N'label3', N'Label', N'Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1360, 105, N'label11', N'Label', N'View Product List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1361, 105, N'chkViewProductSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1362, 105, N'label9', N'Label', N'Edit/Delete Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1363, 105, N'chkEditProductSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1364, 105, N'chkAddProductC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1365, 105, N'label21', N'Label', N'GiftCards', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1366, 105, N'label22', N'Label', N'View Giftcard List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1367, 105, N'chkViewGiftcardSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1368, 105, N'chkViewGiftcardC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1369, 105, N'chkAddGiftCardSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1370, 105, N'label38', N'Label', N'Edit/Delete Giftcard', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1371, 105, N'chkEditMemberCardC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1372, 105, N'label29', N'Label', N'Super Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1373, 105, N'chkNewMemberCardC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1374, 105, N'label30', N'Label', N'Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1375, 105, N'chkEditMemberCardSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1376, 105, N'label67', N'Label', N'Member Card Rule', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1377, 105, N'chkNewMemberCardSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1378, 105, N'label69', N'Label', N'Add New Member Card', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1379, 105, N'label68', N'Label', N'Edit/Delete Member Card', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1380, 105, N'chkStockAgeSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1381, 105, N'label124', N'Label', N'Stock Aging', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1382, 105, N'label110', N'Label', N'Expense', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1383, 105, N'chkNetIncomeC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1384, 105, N'label150', N'Label', N'Net Income', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1385, 105, N'chkNetIncomeSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1386, 105, N'label149', N'Label', N'Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1387, 105, N'label46', N'Label', N'Super Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1388, 105, N'label118', N'Label', N'Product Expire', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1389, 105, N'chkExpenseSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1390, 105, N'chkExpenseC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1391, 105, N'chkProductExpireSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1392, 105, N'chkProductExpireC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1393, 105, N'chkStockAgeC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1394, 105, N'label171', N'Label', N'GWP Transaction', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1395, 105, N'chkGWPSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1396, 105, N'chkGWPC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1397, 105, N'label111', N'Label', N'Report -> Select All >', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1398, 105, N'chkSelectAllReportC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1399, 105, N'chkSelectAllReportSC', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1400, 105, N'label43', N'Label', N'Cashier', N'', N'', N'', N'', 1)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1401, 105, N'chkReportAMRC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1402, 105, N'label42', N'Label', N'Super Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1403, 105, N'chkReportSTC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1404, 105, N'chkReportSTSC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1405, 105, N'chkReportAMRSC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1406, 105, N'chkReportAdjustmentC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1407, 105, N'chkTransactionSummaryC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1408, 105, N'chkReportAdjustmentSC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1409, 105, N'chkTransactionSummarySC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1410, 105, N'chkGrossProfit_C1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1411, 105, N'chkGrossProfit_SC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1412, 105, N'label47', N'Label', N'Gross Profit/Loss', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1413, 105, N'chkTransactionC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1414, 105, N'label94', N'Label', N'Stock Transaction', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1415, 105, N'label93', N'Label', N'Adjustment', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1416, 105, N'label95', N'Label', N'Average Monthly Report', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1417, 105, N'chkTransactionSC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1418, 105, N'label96', N'Label', N'Transaction', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1419, 105, N'chkConsigment_C1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1420, 105, N'chkConsigment_SC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1421, 105, N'label54', N'Label', N'Consigment', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1422, 105, N'label97', N'Label', N'Item Summary', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1423, 105, N'label98', N'Label', N'Purchase Discount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1424, 105, N'label99', N'Label', N'Purchasing', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1425, 105, N'chkReorderReport_C1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1426, 105, N'chkReorderReport_SC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1427, 105, N'label101', N'Label', N'Transaction Detail', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1428, 105, N'label55', N'Label', N'Reorder Report', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1429, 105, N'chkPurchasingDiscount_SC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1430, 105, N'chkProductReport_C1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1431, 105, N'chkProductReport_SC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1432, 105, N'label91', N'Label', N'Product Report', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1433, 105, N'chkPurchasingSC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1434, 105, N'chkTransactionDetail_SC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1435, 105, N'chkCustomerInformation_C1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1436, 105, N'chkCustomerInformation_SC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1437, 105, N'label92', N'Label', N'Customer Information', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1438, 105, N'chkItemSummary_C1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1439, 105, N'chkPurchasingDiscount_C1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1440, 105, N'chkPurchasingC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1441, 105, N'chkTransactionDetail_C1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1442, 105, N'label102', N'Label', N'Transaction Summary', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1443, 105, N'label103', N'Label', N'Daily Sale Summary', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1444, 105, N'chkDailySaleSummary_SC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1445, 105, N'chkDailySaleSummary_C1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1446, 105, N'chkItemSummary_SC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1447, 105, N'label104', N'Label', N'Outstanding Customer', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1448, 105, N'chkOutStandingCustomer_SC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1449, 105, N'chkOutStandingCustomer_C1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1450, 105, N'chkCustomerSale_SC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1451, 105, N'chkCustomerSale_C1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1452, 105, N'label105', N'Label', N'Customer Sales', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1453, 105, N'label106', N'Label', N'Best Seller Items', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1454, 105, N'chkTopBestSellerSC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1455, 105, N'chkTopBestSellerC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1456, 105, N'label107', N'Label', N'Sale Breakdown', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1457, 105, N'label108', N'Label', N'Tax Summary', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1458, 105, N'chkSalebreakdown_SC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1459, 105, N'chkTaxSummary_SC1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1460, 105, N'chkSalebreakdown_C1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1461, 105, N'chkTaxSummary_C1', N'CheckBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1462, 105, N'checkBox2', N'CheckBox', N'checkBox2', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1463, 105, N'checkBox1', N'CheckBox', N'checkBox1', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1464, 106, N'label1', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1465, 106, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1466, 106, N'rdbUnitPrice', N'Radio', N'Unit Price', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1467, 106, N'rdbSaleTrueValue', N'Radio', N'Sale True Price', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1468, 106, N'rdbSegment', N'Radio', N'By Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1469, 106, N'rdbRange', N'Radio', N'By Brand', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1470, 106, N'label3', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1471, 106, N'label2', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1472, 106, N'groupBox4', N'GroupBox', N'By Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1473, 106, N'groupBox3', N'GroupBox', N'Sale List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1474, 106, N'groupBox2', N'GroupBox', N'By Require Sale Value', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1475, 106, N'groupBox1', N'GroupBox', N'Select One', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1476, 106, N'gbPeriod', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1477, 107, N'lblForeignChild', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1478, 107, N'lblForeignAdult', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1479, 107, N'label20', N'Label', N'Child', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1480, 107, N'label14', N'Label', N'Adult', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1481, 107, N'lblLocalChild', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1482, 107, N'lblLocalAdult', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1483, 107, N'label10', N'Label', N'Child', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1484, 107, N'label2', N'Label', N'Adult', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1485, 107, N'label27', N'Label', N'=', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1486, 107, N'lblTicketTotal', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1487, 107, N'label25', N'Label', N'Total Tickets', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1488, 107, N'groupBox2', N'GroupBox', N'Foreign', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1489, 107, N'groupBox3', N'GroupBox', N'Local', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1490, 107, N'txtUnitPrice', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1491, 107, N'label17', N'Label', N'* Qty :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1492, 107, N'label18', N'Label', N'* Product Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1493, 107, N'label19', N'Label', N'* Barcode :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1494, 107, N'lblServiceFee', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1495, 107, N'lblservicepercent', N'Label', N'%', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1496, 107, N'lblservicecharge', N'Label', N'Service Fee', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1497, 107, N'label4', N'Label', N'Total Discount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1498, 107, N'label5', N'Label', N'Total Tax', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1499, 107, N'lblTotal', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1500, 107, N'lblDiscountTotal', N'Label', N'0', N'', N'', N'', N'', 1)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1501, 107, N'lblTaxTotal', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1502, 107, N'label3', N'Label', N'Sub Total', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1503, 107, N'label6', N'Label', N'&Discount Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1504, 107, N'label7', N'Label', N'Pa&yment Method', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1505, 107, N'label12', N'Label', N'Total Qty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1506, 107, N'lblTotalQty', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1507, 107, N'label8', N'Label', N'Tax Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1508, 107, N'label16', N'Label', N'Member Card Discount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1509, 107, N'lblBankPayment', N'Label', N'Bank Payment', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1510, 107, N'dgvSearchProductList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1511, 107, N'label9', N'Label', N'N&ame :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1512, 107, N'label21', N'Label', N'Gift Discount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1513, 107, N'lblGift', N'Label', N'Gift Products :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1514, 107, N'gbTicketing', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1515, 107, N'lblQue', N'Label', N'Next Queue No', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1516, 107, N'lbltable', N'Label', N'Table', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1517, 107, N'chkPrintSlip', N'CheckBox', N'Print Slip', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1518, 107, N'gbFOC', N'GroupBox', N'FOC', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1519, 107, N'chkWholeSale', N'CheckBox', N'Whole Sale', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1520, 107, N'lblMemberType', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1521, 107, N'label15', N'Label', N'&Member ID Number   :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1522, 107, N'label11', N'Label', N'Birthday   :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1523, 107, N'lblBirthday', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1524, 107, N'label13', N'Label', N'NRIC        :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1525, 107, N'lblNRIC', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1526, 107, N'label1', N'Label', N'S&elect Customer        :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1527, 107, N'gbSearchProduct', N'GroupBox', N'Search Product Code By Product Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1528, 107, N'dgvSalesItem', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1529, 108, N'chkCustomSKU', N'CheckBox', N'Use Custom SKU', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1530, 108, N'chkIdleDetect', N'CheckBox', N'Detect Application Idle', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1531, 108, N'label20', N'Label', N'Mins', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1532, 108, N'label21', N'Label', N'Log out after', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1533, 108, N'label19', N'Label', N'%', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1534, 108, N'label17', N'Label', N'Service Fee', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1535, 108, N'rdoFeFo', N'Radio', N'First Expire First Out', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1536, 108, N'rdoLiFo', N'Radio', N'Last In First Out', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1537, 108, N'rdoFiFo', N'Radio', N'First In First Out', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1538, 108, N'chkDynamic', N'CheckBox', N'Allow Dynamic Price', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1539, 108, N'chkUseStockAutoGenerate', N'CheckBox', N'Use Stock Auto Generate Code', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1540, 108, N'label9', N'Label', N'Row Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1541, 108, N'label10', N'Label', N'City Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1542, 108, N'label13', N'Label', N'Currency', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1543, 108, N'label8', N'Label', N'Tax Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1544, 108, N'lblCity', N'Label', N'City', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1545, 108, N'lbl', N'Label', N'City', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1546, 108, N'txtOpeningHours', N'Label', N'Opening Hours', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1547, 108, N'txtPhoneNo', N'Label', N'Phone', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1548, 108, N'txtBranchName', N'Label', N'Branch Name Or Address', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1549, 108, N'txtShopName', N'Label', N'Shop Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1550, 108, N'label7', N'Label', N'Opening Hours', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1551, 108, N'label5', N'Label', N'Branch Name Or Address', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1552, 108, N'label4', N'Label', N'Shop Name        ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1553, 108, N'label6', N'Label', N'Phone', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1554, 108, N'label16', N'Label', N'Default Shop     ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1555, 108, N'label11', N'Label', N'Company Start Date', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1556, 108, N'groupBox9', N'GroupBox', N'CustomSKU', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1557, 108, N'gbIdleLogout', N'GroupBox', N'Idle Logout', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1558, 108, N'gbServiceCharge', N'GroupBox', N'Service Charge', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1559, 108, N'gbInventoryMethods', N'GroupBox', N'Inventory Control Methods', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1560, 108, N'gbDynamicPrice', N'GroupBox', N'Dynamic Price', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1561, 108, N'groupBox8', N'GroupBox', N'Default Language', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1562, 108, N'groupBox7', N'GroupBox', N'Stock Auto Generate Code', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1563, 108, N'groupBox4', N'GroupBox', N'Default Row For Top Sales Report', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1564, 108, N'groupBox5', N'GroupBox', N'Default City Selection', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1565, 108, N'groupBox6', N'GroupBox', N'Default Currency', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1566, 108, N'groupBox3', N'GroupBox', N'Default Tax Percent Selection', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1567, 108, N'groupBox2', N'GroupBox', N'Shop Information', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1568, 108, N'chkBO', N'CheckBox', N'IsBackOffice', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1569, 108, N'chkProductImage', N'CheckBox', N'Show ProductImage in A4 Reports', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1570, 108, N'chkUpper', N'CheckBox', N'UpperCase ProductName', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1571, 108, N'chkTopMost', N'CheckBox', N'Top Most', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1572, 108, N'chkAllowMinimize', N'CheckBox', N'Allow Minimize', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1573, 108, N'chkTicketSale', N'CheckBox', N'Ticket Sale', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1574, 108, N'chkusequeue', N'CheckBox', N'Use Queue', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1575, 108, N'chkUseTable', N'CheckBox', N'Use Table', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1576, 108, N'chkSourceCode', N'CheckBox', N'IsSourceCode', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1577, 108, N'label18', N'Label', N'POS_ID', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1578, 108, N'rdoSlipPrinter', N'Radio', N'Slip Printer', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1579, 108, N'rdoA4Printer', N'Radio', N'A4 Printer', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1580, 108, N'lblDefaultPrinter', N'Label', N'Default Printer', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1581, 108, N'label3', N'Label', N'Slip Printer', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1582, 108, N'label1', N'Label', N'Barcode Printer', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1583, 108, N'label2', N'Label', N'A4 Printer', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1584, 108, N'label15', N'Label', N'Number of Copies :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1585, 108, N'label14', N'Label', N'Logo :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1586, 108, N'label12', N'Label', N'Footer Page    :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1587, 108, N'groupBox1', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1588, 109, N'label5', N'Label', N'Branch Name Or Address', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1589, 109, N'label4', N'Label', N'* Shop Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1590, 109, N'label6', N'Label', N'Phone', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1591, 109, N'label7', N'Label', N'Opening Hours', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1592, 109, N'label1', N'Label', N'* Shop Code', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1593, 109, N'lbl', N'Label', N'City', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1594, 109, N'label2', N'Label', N'* Mandatory Fileds', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1595, 109, N'dgvshopview', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1596, 109, N'groupBox2', N'GroupBox', N'Create Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1597, 109, N'groupBox1', N'GroupBox', N'Shop List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1598, 110, N'label1', N'Label', N'10,000', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1599, 110, N'label2', N'Label', N'500', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1600, 110, N'label3', N'Label', N'50', N'', N'', N'', N'', 1)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1601, 110, N'label4', N'Label', N'5,000', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1602, 110, N'label5', N'Label', N'200', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1603, 110, N'label6', N'Label', N'20', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1604, 110, N'label9', N'Label', N'10', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1605, 110, N'label8', N'Label', N'100', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1606, 110, N'label7', N'Label', N'1,000', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1607, 110, N'label13', N'Label', N'Other Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1608, 110, N'lblTotal', N'Label', N'0', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1609, 110, N'label10', N'Label', N'Total', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1610, 111, N'rdbDate', N'Radio', N'By Date', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1611, 111, N'rdbId', N'Radio', N'By Stock Code', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1612, 111, N'label4', N'Label', N'Stock Code', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1613, 111, N'label3', N'Label', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1614, 111, N'rdoStockTranfer', N'Radio', N'Stock Transfer/Return  (To Other Shops)', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1615, 111, N'rdoStockIn', N'Radio', N'Stock Receive (For Own Shop)', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1616, 111, N'rdoapproved', N'Radio', N'Approved', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1617, 111, N'rdopending', N'Radio', N'Pending', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1618, 111, N'label2', N'Label', N'To Date', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1619, 111, N'label1', N'Label', N'From Date', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1620, 111, N'groupBox5', N'GroupBox', N'Search For Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1621, 111, N'groupBox2', N'GroupBox', N'By Code', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1622, 111, N'dgvStockReceive', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1623, 111, N'groupBox4', N'GroupBox', N'Please Select one', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1624, 111, N'groupBox3', N'GroupBox', N'By Status', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1625, 111, N'gpByPeriod', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1626, 112, N'label3', N'Label', N'Month:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1627, 112, N'label1', N'Label', N'Year :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1628, 112, N'groupBox2', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1629, 113, N'label3', N'Label', N'Month:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1630, 113, N'label1', N'Label', N'Year :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1631, 113, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1632, 113, N'groupBox2', N'GroupBox', N'By Period:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1633, 114, N'rdoStockReturn', N'Radio', N'Stock Return', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1634, 114, N'rdostockTrans', N'Radio', N'Stock Transfer', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1635, 114, N'rdoStockIn', N'Radio', N'Stock In', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1636, 114, N'label6', N'Label', N'* Qty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1637, 114, N'label5', N'Label', N'* Bar Code', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1638, 114, N'label7', N'Label', N'* Product', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1639, 114, N'dgvProductList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1640, 114, N'lblToshop', N'Label', N'*To Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1641, 114, N'lblFromshop', N'Label', N'* From Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1642, 114, N'label2', N'Label', N'Code No', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1643, 114, N'label1', N'Label', N'Date', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1644, 114, N'groupBox3', N'GroupBox', N'Select one', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1645, 114, N'groupBox2', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1646, 114, N'groupBox1', N'GroupBox', N'Stock In', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1647, 115, N'label1', N'Label', N'Supplier Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1648, 115, N'lblName', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1649, 115, N'label3', N'Label', N'Phone Number :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1650, 115, N'lblPhNo', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1651, 115, N'label5', N'Label', N'Email :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1652, 115, N'lblEnail', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1653, 115, N'label7', N'Label', N'Address :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1654, 115, N'lblAddress', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1655, 115, N'label9', N'Label', N'Contact Person :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1656, 115, N'lblContactPerson', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1657, 115, N'label11', N'Label', N'Old Credit Amount :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1658, 115, N'lblCreditAmount', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1659, 116, N'lblsName', N'Label', N'Supplier Name    :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1660, 116, N'dgvSupplierList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1661, 116, N'groupBox2', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1662, 116, N'groupBox1', N'GroupBox', N'Supplier List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1663, 117, N'dgvTaxList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1664, 117, N'lblStatus', N'Label', N'Add', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1665, 117, N'label1', N'Label', N'Name  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1666, 117, N'label2', N'Label', N'Rate (%) :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1667, 117, N'groupBox2', N'GroupBox', N'Taxex List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1668, 117, N'groupBox1', N'GroupBox', N'Add Taxes', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1669, 118, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1670, 118, N'rdbRefund', N'Radio', N'Refund', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1671, 118, N'rdbSale', N'Radio', N'Sale', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1672, 118, N'label3', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1673, 118, N'label2', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1674, 118, N'gbList', N'GroupBox', N'Sale Taxes Report', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1675, 118, N'groupBox2', N'GroupBox', N'By Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1676, 118, N'groupBox1', N'GroupBox', N'By Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1677, 119, N'label5', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1678, 119, N'label4', N'Label', N'Total Row :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1679, 119, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1680, 119, N'label3', N'Label', N'Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1681, 119, N'lblPeriod', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1682, 119, N'label2', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1683, 119, N'label1', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1684, 119, N'rdbAmount', N'Radio', N'By Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1685, 119, N'rdbQty', N'Radio', N'By Quantity', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1686, 119, N'groupBox4', N'GroupBox', N'By Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1687, 119, N'groupBox3', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1688, 119, N'gbTransactionList', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1689, 119, N'groupBox2', N'GroupBox', N'Report Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1690, 119, N'groupBox1', N'GroupBox', N'Select Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1691, 120, N'label2', N'Label', N'Amount:', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1692, 120, N'label1', N'Label', N'Card No :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1693, 120, N'groupBox1', N'GroupBox', N'Top Up', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1694, 121, N'chkCredit', N'CheckBox', N'Credit', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1695, 121, N'chkGiftCard', N'CheckBox', N'Gift Card', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1696, 121, N'chkCash', N'CheckBox', N'Cash', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1697, 121, N'chkCounter', N'CheckBox', N'ByCounter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1698, 121, N'chkCashier', N'CheckBox', N'ByCashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1699, 121, N'lblCounterName', N'Label', N'Counter Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1700, 121, N'lblCashierName', N'Label', N'Cashier Name', N'', N'', N'', N'', 1)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1701, 121, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1702, 121, N'label3', N'Label', N'Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1703, 121, N'lblPeriod', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1704, 121, N'label2', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1705, 121, N'label1', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1706, 121, N'rdbSummary', N'Radio', N'Summary', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1707, 121, N'rdbDebt', N'Radio', N'Settlement ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1708, 121, N'rdbRefund', N'Radio', N'Refund', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1709, 121, N'rdbSale', N'Radio', N'Sale', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1710, 121, N'gbPaymentType', N'GroupBox', N'Report Payment Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1711, 121, N'groupBox3', N'GroupBox', N'By Cashier or Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1712, 121, N'gbTransactionList', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1713, 121, N'groupBox2', N'GroupBox', N'Report Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1714, 121, N'groupBox1', N'GroupBox', N'Report Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1715, 122, N'label7', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1716, 122, N'label6', N'Label', N'Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1717, 122, N'label5', N'Label', N'Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1718, 122, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1719, 122, N'label4', N'Label', N'Sub Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1720, 122, N'label3', N'Label', N'Main Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1721, 122, N'label2', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1722, 122, N'label1', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1723, 122, N'rdoFOC', N'Radio', N'FOC', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1724, 122, N'rdbRefund', N'Radio', N'Refund', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1725, 122, N'rdbSale', N'Radio', N'Sale', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1726, 122, N'groupBox6', N'GroupBox', N'By Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1727, 122, N'groupBox5', N'GroupBox', N'By Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1728, 122, N'groupBox4', N'GroupBox', N'By Brand', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1729, 122, N'gbList', N'GroupBox', N'Sale ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1730, 122, N'groupBox3', N'GroupBox', N'By Category', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1731, 122, N'groupBox2', N'GroupBox', N'Report Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1732, 122, N'groupBox1', N'GroupBox', N'Report Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1733, 123, N'label20', N'Label', N':', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1734, 123, N'lblAmountFromGiftCard', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1735, 123, N'label19', N'Label', N':', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1736, 123, N'lblOutstandingAmount', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1737, 123, N'label18', N'Label', N':', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1738, 123, N'lblRefundAmt', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1739, 123, N'label17', N'Label', N':', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1740, 123, N'lblRecieveAmunt', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1741, 123, N'label16', N'Label', N':', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1742, 123, N'lblTotal', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1743, 123, N'label15', N'Label', N':', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1744, 123, N'lblTotalTax', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1745, 123, N'label14', N'Label', N':', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1746, 123, N'lblMCDiscount', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1747, 123, N'label13', N'Label', N':', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1748, 123, N'lblDiscount', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1749, 123, N'lblPaymentMethod1', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1750, 123, N'label12', N'Label', N':', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1751, 123, N'lblAmountFromGiftcardTitle', N'Label', N'Amount From Giftcards ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1752, 123, N'lblPrevTitle', N'Label', N'Used Prepaid Amount ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1753, 123, N'label7', N'Label', N'Refund Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1754, 123, N'lblR', N'Label', N'Received Amount ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1755, 123, N'label4', N'Label', N'Tax Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1756, 123, N'label6', N'Label', N'Member Card Discount ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1757, 123, N'lblDis', N'Label', N'Total Discount Amount', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1758, 123, N'label10', N'Label', N'Payment Method', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1759, 123, N'lblt', N'Label', N'Total ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1760, 123, N'label8', N'Label', N'(Including Discount Amount, Member Card Discount, Tax Amount)', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1761, 123, N'label9', N'Label', N'Note', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1762, 123, N'lblCustomerName', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1763, 123, N'label5', N'Label', N'Customer Name :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1764, 123, N'lblTime', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1765, 123, N'lblDate', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1766, 123, N'lblSalePerson', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1767, 123, N'dgvTransactionDetail', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1768, 123, N'label3', N'Label', N'Time :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1769, 123, N'label2', N'Label', N'Date :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1770, 123, N'label1', N'Label', N'Sale Person :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1771, 124, N'label4', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1772, 124, N'rdbDate', N'Radio', N'By Date', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1773, 124, N'rdbId', N'Radio', N'By Transaction Id', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1774, 124, N'label3', N'Label', N'Transaction Id', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1775, 124, N'label1', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1776, 124, N'label2', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1777, 124, N'dgvTransactionList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1778, 124, N'groupBox2', N'GroupBox', N'By Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1779, 124, N'groupBox4', N'GroupBox', N'Search For Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1780, 124, N'gbId', N'GroupBox', N'By Transaction Id', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1781, 124, N'gbDate', N'GroupBox', N'By Date', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1782, 124, N'groupBox1', N'GroupBox', N'Transaction List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1783, 125, N'lblCounterName', N'Label', N'Counter Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1784, 125, N'lblCashierName', N'Label', N'Cashier Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1785, 125, N'rbdCounter', N'Radio', N'Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1786, 125, N'rdbCashier', N'Radio', N'Cashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1787, 125, N'groupBox1', N'GroupBox', N'By Cashier or Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1788, 126, N'label4', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1789, 126, N'chkOnePay', N'CheckBox', N'One Pay', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1790, 126, N'chkWavePay', N'CheckBox', N'Wave Pay', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1791, 126, N'chkAYAPay', N'CheckBox', N'AYA Pay', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1792, 126, N'chkCBPay', N'CheckBox', N'CB Pay', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1793, 126, N'chkKBZPay', N'CheckBox', N'KBZ Pay', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1794, 126, N'chkUnionPay', N'CheckBox', N'Union Pay', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1795, 126, N'chkMaster', N'CheckBox', N'Master', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1796, 126, N'chkVisa', N'CheckBox', N'Visa', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1797, 126, N'chkJCB', N'CheckBox', N'JCB', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1798, 126, N'chkMPU', N'CheckBox', N'MPU', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1799, 126, N'chkSaiPay', N'CheckBox', N'Sai Sai Pay', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1800, 126, N'chkBankTransfer', N'CheckBox', N'Bank Transfer', N'', N'', N'', N'', 1)
GO
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1801, 126, N'chkBank', N'CheckBox', N'Bank', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1802, 126, N'gbBank', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1803, 126, N'chkTester', N'CheckBox', N'Tester', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1804, 126, N'chkFOC', N'CheckBox', N'FOC', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1805, 126, N'chkCredit', N'CheckBox', N'Credit', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1806, 126, N'chkGiftCard', N'CheckBox', N'Gift Card', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1807, 126, N'chkCash', N'CheckBox', N'Cash', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1808, 126, N'chkCounter', N'CheckBox', N'ByCounter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1809, 126, N'chkCashier', N'CheckBox', N'ByCashier', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1810, 126, N'lblCounterName', N'Label', N'Counter Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1811, 126, N'lblCashierName', N'Label', N'Cashier Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1812, 126, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1813, 126, N'label3', N'Label', N'Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1814, 126, N'lblPeriod', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1815, 126, N'label2', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1816, 126, N'label1', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1817, 126, N'rdbSummary', N'Radio', N'Summary', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1818, 126, N'rdbDebt', N'Radio', N'Settlement ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1819, 126, N'rdbRefund', N'Radio', N'Refund', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1820, 126, N'rdbSale', N'Radio', N'Sale', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1821, 126, N'groupBox4', N'GroupBox', N'Report by shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1822, 126, N'gbPaymentType', N'GroupBox', N'Report Payment Type', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1823, 126, N'groupBox3', N'GroupBox', N'By Cashier or Counter', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1824, 126, N'gbTransactionList', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1825, 126, N'groupBox2', N'GroupBox', N'Report Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1826, 126, N'groupBox1', N'GroupBox', N'Report Catergory', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1827, 127, N'label4', N'Label', N'shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1828, 127, N'LblLoading', N'Label', N'Loading...', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1829, 127, N'label3', N'Label', N'Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1830, 127, N'lblPeriod', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1831, 127, N'label2', N'Label', N'To', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1832, 127, N'label1', N'Label', N'From', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1833, 127, N'groupBox1', N'GroupBox', N'By shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1834, 127, N'gbTransactionList', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1835, 127, N'groupBox2', N'GroupBox', N'Time Period', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1836, 128, N'txtUnitNormal', N'Label', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1837, 128, N'txtUnitMax', N'Label', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1838, 128, N'lblFromPerPurPrice', N'Label', N'Per Purchase Price', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1839, 128, N'txtMaxPurPrice', N'Label', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1840, 128, N'txtNormalPurPrice', N'Label', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1841, 128, N'lblToPerPurPrice', N'Label', N'Per Purchase Price', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1842, 128, N'lblMaxBalance', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1843, 128, N'lblNormalBalance', N'Label', N'-', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1844, 128, N'label4', N'Label', N'Total Converted Normal Qty', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1845, 128, N'lblIncludingPack', N'Label', N'Pieces Per Pack', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1846, 128, N'label3', N'Label', N'Convert Qty (Maximum Product)', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1847, 128, N'label2', N'Label', N'Current Stock Balance', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1848, 128, N'label1', N'Label', N'To Product (Normal Stock Unit)', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1849, 128, N'lblStockMax', N'Label', N'From Product (Maximum Stock Unit)', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1850, 128, N'Balance', N'Label', N'Current Stock Balance', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1851, 129, N'label2', N'Label', N'To  ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1852, 129, N'label1', N'Label', N'From  ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1853, 129, N'label7', N'Label', N'Maximum Product    ', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1854, 129, N'groupBox4', N'GroupBox', N'Search By :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1855, 129, N'dgvConversionList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1856, 130, N'dgvUnitList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1857, 130, N'label1', N'Label', N'Name  :', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1858, 130, N'groupBox2', N'GroupBox', N'Unit List', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1859, 130, N'groupBox1', N'GroupBox', N'Add Unit Name', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1860, 131, N'label1', N'Label', N'Shop', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1861, 131, N'txtShop', N'Label', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1862, 131, N'groupBox1', N'GroupBox', N'', N'', N'', N'', N'', 0)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1863, 131, N'dgvSalesPersonList', N'GridView', N'', N'', N'', N'', N'', 1)
INSERT [dbo].[pjForms_Localization] ([Id], [FormId], [ControlName], [Type], [Eng], [ZawGyi], [MM3], [Other1], [Other2], [AllowToLoad]) VALUES (1864, 132, N'dgvViewTicket', N'GridView', N'', N'', N'', N'', N'', 1)
SET IDENTITY_INSERT [dbo].[Setting] ON 

INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (1, N'barcode_printer', N'Plz Choose Bar Code Printer')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (2, N'a4_printer', N'Microsoft Print to PDF')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (3, N'slip_printer_counter1', N'Microsoft Print to PDF')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (4, N'shop_name', N'MainOffice')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (5, N'branch_name', N'')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (6, N'phone_number', N'')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (7, N'opening_hours', N'')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (8, N'default_tax_rate', N'1')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (9, N'default_city_id', N'1')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (10, N'default_top_sale_row', N'1')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (11, N'default_currency', N'1')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (12, N'Company_StartDate', N'2/10/2023 9:47:07 AM')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (13, N'default_printer', N'Slip Printer')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (14, N'IsBackOffice', N'1')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (15, N'default_font', N'English')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (16, N'IsSourcecode', N'False')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (17, N'pos_id', N'0')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (18, N'retrieve_pattern', N'fefo')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (19, N'allow_dynamic', N'False')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (20, N'app_mode', N'Production')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (21, N'usetable', N'False')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (22, N'usequeue', N'False')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (23, N'service_fee', N'0')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (24, N'detect_idle', N'False')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (25, N'idle_Time', N'1')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (26, N'ticketsale', N'False')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (27, N'allow_minimize', N'True')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (28, N'topmost', N'False')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (29, N'customsku', N'False')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (30, N'uppercase', N'False')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (31, N'a4image', N'False')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (32, N'UseStockAutoGenerate', N'False')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (33, N'FooterPage', N'')
INSERT [dbo].[Setting] ([Id], [Key], [Value]) VALUES (34, N'default_noOfCopies', N'1')
SET IDENTITY_INSERT [dbo].[Setting] OFF
SET IDENTITY_INSERT [dbo].[Shop] ON 

INSERT [dbo].[Shop] ([Id], [ShopName], [Address], [PhoneNumber], [OpeningHours], [CityId], [ShortCode], [IsDefaultShop]) VALUES (1, N'MainOffice', NULL, NULL, NULL, 1, N'MO', 1)
SET IDENTITY_INSERT [dbo].[Shop] OFF
SET IDENTITY_INSERT [dbo].[Tax] ON 

INSERT [dbo].[Tax] ([Id], [Name], [TaxPercent], [IsDelete]) VALUES (1, N'None', CAST(0.00 AS Decimal(5, 2)), 0)
SET IDENTITY_INSERT [dbo].[Tax] OFF
SET IDENTITY_INSERT [dbo].[User] ON 

INSERT [dbo].[User] ([Id], [Name], [UserRoleId], [Password], [DateTime], [ShopId], [MenuPermission], [UserCodeNo], [CreatedBy], [CreatedDate], [UpdatedBy], [UpdatedDate]) VALUES (4, N'sourcecodeadmin', 1, N'2BMH+NlLeYZl8t03W04flA==', CAST(N'2023-02-10 09:47:07.757' AS DateTime), 1, N'Both', N'USMO202302102', NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[User] OFF
SET IDENTITY_INSERT [dbo].[UserRole] ON 

INSERT [dbo].[UserRole] ([Id], [RoleName]) VALUES (1, N'Admin')
INSERT [dbo].[UserRole] ([Id], [RoleName]) VALUES (2, N'Super Cashier')
INSERT [dbo].[UserRole] ([Id], [RoleName]) VALUES (3, N'Cashier')
SET IDENTITY_INSERT [dbo].[UserRole] OFF
ALTER TABLE [dbo].[User] ADD  CONSTRAINT [DF_User_DateTime]  DEFAULT (getdate()) FOR [DateTime]
GO
ALTER TABLE [dbo].[Adjustment]  WITH CHECK ADD  CONSTRAINT [FK_Adjustment_AdjustmentType] FOREIGN KEY([AdjustmentTypeId])
REFERENCES [dbo].[AdjustmentType] ([Id])
GO
ALTER TABLE [dbo].[Adjustment] CHECK CONSTRAINT [FK_Adjustment_AdjustmentType]
GO
ALTER TABLE [dbo].[Adjustment]  WITH CHECK ADD  CONSTRAINT [FK_Adjustment_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[Adjustment] CHECK CONSTRAINT [FK_Adjustment_Product]
GO
ALTER TABLE [dbo].[Adjustment]  WITH CHECK ADD  CONSTRAINT [FK_Adjustment_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Adjustment] CHECK CONSTRAINT [FK_Adjustment_User]
GO
ALTER TABLE [dbo].[ConsignmentSettlement]  WITH CHECK ADD  CONSTRAINT [FK_ConsignmentSettlement_ConsignmentSettlement] FOREIGN KEY([Id])
REFERENCES [dbo].[ConsignmentSettlement] ([Id])
GO
ALTER TABLE [dbo].[ConsignmentSettlement] CHECK CONSTRAINT [FK_ConsignmentSettlement_ConsignmentSettlement]
GO
ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_City] FOREIGN KEY([CityId])
REFERENCES [dbo].[City] ([Id])
GO
ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_City]
GO
ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_MemberType] FOREIGN KEY([MemberTypeID])
REFERENCES [dbo].[MemberType] ([Id])
GO
ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_MemberType]
GO
ALTER TABLE [dbo].[DailyRecord]  WITH CHECK ADD  CONSTRAINT [FK_DailyRecord_Counter] FOREIGN KEY([CounterId])
REFERENCES [dbo].[Counter] ([Id])
GO
ALTER TABLE [dbo].[DailyRecord] CHECK CONSTRAINT [FK_DailyRecord_Counter]
GO
ALTER TABLE [dbo].[DeleteLog]  WITH CHECK ADD  CONSTRAINT [FK_DeleteLog_Counter] FOREIGN KEY([CounterId])
REFERENCES [dbo].[Counter] ([Id])
GO
ALTER TABLE [dbo].[DeleteLog] CHECK CONSTRAINT [FK_DeleteLog_Counter]
GO
ALTER TABLE [dbo].[DeleteLog]  WITH CHECK ADD  CONSTRAINT [FK_DeleteLog_Transaction] FOREIGN KEY([TransactionId])
REFERENCES [dbo].[Transaction] ([Id])
GO
ALTER TABLE [dbo].[DeleteLog] CHECK CONSTRAINT [FK_DeleteLog_Transaction]
GO
ALTER TABLE [dbo].[DeleteLog]  WITH CHECK ADD  CONSTRAINT [FK_DeleteLog_TransactionDetail] FOREIGN KEY([TransactionDetailId])
REFERENCES [dbo].[TransactionDetail] ([Id])
GO
ALTER TABLE [dbo].[DeleteLog] CHECK CONSTRAINT [FK_DeleteLog_TransactionDetail]
GO
ALTER TABLE [dbo].[DeleteLog]  WITH CHECK ADD  CONSTRAINT [FK_DeleteLog_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[DeleteLog] CHECK CONSTRAINT [FK_DeleteLog_User]
GO
ALTER TABLE [dbo].[ExchangeRateForTransaction]  WITH CHECK ADD  CONSTRAINT [FK_ExchangeRateForTransaction_Currency] FOREIGN KEY([CurrencyId])
REFERENCES [dbo].[Currency] ([Id])
GO
ALTER TABLE [dbo].[ExchangeRateForTransaction] CHECK CONSTRAINT [FK_ExchangeRateForTransaction_Currency]
GO
ALTER TABLE [dbo].[ExchangeRateForTransaction]  WITH CHECK ADD  CONSTRAINT [FK_ExchangeRateForTransaction_Transaction] FOREIGN KEY([TransactionId])
REFERENCES [dbo].[Transaction] ([Id])
GO
ALTER TABLE [dbo].[ExchangeRateForTransaction] CHECK CONSTRAINT [FK_ExchangeRateForTransaction_Transaction]
GO
ALTER TABLE [dbo].[Expense]  WITH CHECK ADD  CONSTRAINT [FK_Expense_ExpenseCategory] FOREIGN KEY([ExpenseCategoryId])
REFERENCES [dbo].[ExpenseCategory] ([Id])
GO
ALTER TABLE [dbo].[Expense] CHECK CONSTRAINT [FK_Expense_ExpenseCategory]
GO
ALTER TABLE [dbo].[Expense]  WITH CHECK ADD  CONSTRAINT [FK_Expense_User] FOREIGN KEY([CreatedUser])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Expense] CHECK CONSTRAINT [FK_Expense_User]
GO
ALTER TABLE [dbo].[ExpenseDetail]  WITH CHECK ADD  CONSTRAINT [FK_ExpenseDetail_Expense] FOREIGN KEY([ExpenseId])
REFERENCES [dbo].[Expense] ([Id])
GO
ALTER TABLE [dbo].[ExpenseDetail] CHECK CONSTRAINT [FK_ExpenseDetail_Expense]
GO
ALTER TABLE [dbo].[GiftCardInTransaction]  WITH CHECK ADD  CONSTRAINT [FK_GiftCardInCustomer_GiftCard] FOREIGN KEY([GiftCardId])
REFERENCES [dbo].[GiftCard] ([Id])
GO
ALTER TABLE [dbo].[GiftCardInTransaction] CHECK CONSTRAINT [FK_GiftCardInCustomer_GiftCard]
GO
ALTER TABLE [dbo].[GiftCardInTransaction]  WITH CHECK ADD  CONSTRAINT [FK_GiftCardInCustomer_GiftCardInCustomer] FOREIGN KEY([TransactionId])
REFERENCES [dbo].[Transaction] ([Id])
GO
ALTER TABLE [dbo].[GiftCardInTransaction] CHECK CONSTRAINT [FK_GiftCardInCustomer_GiftCardInCustomer]
GO
ALTER TABLE [dbo].[GiftCardInTransaction]  WITH CHECK ADD  CONSTRAINT [FK_GiftCardInTransaction_Transaction] FOREIGN KEY([TransactionId])
REFERENCES [dbo].[Transaction] ([Id])
GO
ALTER TABLE [dbo].[GiftCardInTransaction] CHECK CONSTRAINT [FK_GiftCardInTransaction_Transaction]
GO
ALTER TABLE [dbo].[GiftSystem]  WITH CHECK ADD  CONSTRAINT [FK_GiftSystem_Brand] FOREIGN KEY([FilterBrandId])
REFERENCES [dbo].[Brand] ([Id])
GO
ALTER TABLE [dbo].[GiftSystem] CHECK CONSTRAINT [FK_GiftSystem_Brand]
GO
ALTER TABLE [dbo].[GiftSystem]  WITH CHECK ADD  CONSTRAINT [FK_GiftSystem_Product] FOREIGN KEY([MustIncludeProductId])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[GiftSystem] CHECK CONSTRAINT [FK_GiftSystem_Product]
GO
ALTER TABLE [dbo].[GiftSystem]  WITH CHECK ADD  CONSTRAINT [FK_GiftSystem_Product1] FOREIGN KEY([GiftProductId])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[GiftSystem] CHECK CONSTRAINT [FK_GiftSystem_Product1]
GO
ALTER TABLE [dbo].[GiftSystem]  WITH CHECK ADD  CONSTRAINT [FK_GiftSystem_ProductCategory] FOREIGN KEY([FilterCategoryId])
REFERENCES [dbo].[ProductCategory] ([Id])
GO
ALTER TABLE [dbo].[GiftSystem] CHECK CONSTRAINT [FK_GiftSystem_ProductCategory]
GO
ALTER TABLE [dbo].[GiftSystem]  WITH CHECK ADD  CONSTRAINT [FK_GiftSystem_ProductSubCategory] FOREIGN KEY([FilterSubCategoryId])
REFERENCES [dbo].[ProductSubCategory] ([Id])
GO
ALTER TABLE [dbo].[GiftSystem] CHECK CONSTRAINT [FK_GiftSystem_ProductSubCategory]
GO
ALTER TABLE [dbo].[GiftSystemInTransaction]  WITH CHECK ADD  CONSTRAINT [FK_GiftSystemInTransaction_GiftSystem] FOREIGN KEY([GiftSystemId])
REFERENCES [dbo].[GiftSystem] ([Id])
GO
ALTER TABLE [dbo].[GiftSystemInTransaction] CHECK CONSTRAINT [FK_GiftSystemInTransaction_GiftSystem]
GO
ALTER TABLE [dbo].[GiftSystemInTransaction]  WITH CHECK ADD  CONSTRAINT [FK_GiftSystemInTransaction_Transaction] FOREIGN KEY([TransactionId])
REFERENCES [dbo].[Transaction] ([Id])
GO
ALTER TABLE [dbo].[GiftSystemInTransaction] CHECK CONSTRAINT [FK_GiftSystemInTransaction_Transaction]
GO
ALTER TABLE [dbo].[MainPurchase]  WITH CHECK ADD  CONSTRAINT [FK_MainPurchase_Supplier] FOREIGN KEY([SupplierId])
REFERENCES [dbo].[Supplier] ([Id])
GO
ALTER TABLE [dbo].[MainPurchase] CHECK CONSTRAINT [FK_MainPurchase_Supplier]
GO
ALTER TABLE [dbo].[MemberCardRule]  WITH CHECK ADD  CONSTRAINT [FK_MemberCardRule_MemberType] FOREIGN KEY([MemberTypeId])
REFERENCES [dbo].[MemberType] ([Id])
GO
ALTER TABLE [dbo].[MemberCardRule] CHECK CONSTRAINT [FK_MemberCardRule_MemberType]
GO
ALTER TABLE [dbo].[NoveltySystem]  WITH CHECK ADD  CONSTRAINT [FK_NoveltySystem_Brand] FOREIGN KEY([BrandId])
REFERENCES [dbo].[Brand] ([Id])
GO
ALTER TABLE [dbo].[NoveltySystem] CHECK CONSTRAINT [FK_NoveltySystem_Brand]
GO
ALTER TABLE [dbo].[pjForms_Localization]  WITH CHECK ADD  CONSTRAINT [FK_Forms_Localization_Forms_Localization] FOREIGN KEY([FormId])
REFERENCES [dbo].[pjForms] ([Id])
GO
ALTER TABLE [dbo].[pjForms_Localization] CHECK CONSTRAINT [FK_Forms_Localization_Forms_Localization]
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_Brand] FOREIGN KEY([BrandId])
REFERENCES [dbo].[Brand] ([Id])
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_Brand]
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_ConsignmentCounter] FOREIGN KEY([ConsignmentCounterId])
REFERENCES [dbo].[ConsignmentCounter] ([Id])
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_ConsignmentCounter]
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_ProductCategory] FOREIGN KEY([ProductCategoryId])
REFERENCES [dbo].[ProductCategory] ([Id])
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_ProductCategory]
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_ProductType] FOREIGN KEY([ProductSubCategoryId])
REFERENCES [dbo].[ProductSubCategory] ([Id])
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_ProductType]
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_Tax] FOREIGN KEY([TaxId])
REFERENCES [dbo].[Tax] ([Id])
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_Tax]
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_Unit] FOREIGN KEY([UnitId])
REFERENCES [dbo].[Unit] ([Id])
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_Unit]
GO
ALTER TABLE [dbo].[ProductInNovelty]  WITH CHECK ADD  CONSTRAINT [FK_ProductInNovelty_NoveltySystem] FOREIGN KEY([NoveltySystemId])
REFERENCES [dbo].[NoveltySystem] ([Id])
GO
ALTER TABLE [dbo].[ProductInNovelty] CHECK CONSTRAINT [FK_ProductInNovelty_NoveltySystem]
GO
ALTER TABLE [dbo].[ProductInNovelty]  WITH CHECK ADD  CONSTRAINT [FK_ProductInNovelty_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[ProductInNovelty] CHECK CONSTRAINT [FK_ProductInNovelty_Product]
GO
ALTER TABLE [dbo].[ProductPriceChange]  WITH CHECK ADD  CONSTRAINT [FK_ProductPriceChange_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[ProductPriceChange] CHECK CONSTRAINT [FK_ProductPriceChange_Product]
GO
ALTER TABLE [dbo].[ProductPriceChange]  WITH CHECK ADD  CONSTRAINT [FK_ProductPriceChange_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[ProductPriceChange] CHECK CONSTRAINT [FK_ProductPriceChange_User]
GO
ALTER TABLE [dbo].[ProductQuantityChange]  WITH CHECK ADD  CONSTRAINT [FK_ProductQuantityChange_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[ProductQuantityChange] CHECK CONSTRAINT [FK_ProductQuantityChange_Product]
GO
ALTER TABLE [dbo].[ProductQuantityChange]  WITH CHECK ADD  CONSTRAINT [FK_ProductQuantityChange_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[ProductQuantityChange] CHECK CONSTRAINT [FK_ProductQuantityChange_User]
GO
ALTER TABLE [dbo].[ProductSubCategory]  WITH CHECK ADD  CONSTRAINT [FK_ProductSubCategory_ProductCategory] FOREIGN KEY([ProductCategoryId])
REFERENCES [dbo].[ProductCategory] ([Id])
GO
ALTER TABLE [dbo].[ProductSubCategory] CHECK CONSTRAINT [FK_ProductSubCategory_ProductCategory]
GO
ALTER TABLE [dbo].[PurchaseDeleteLog]  WITH CHECK ADD  CONSTRAINT [FK_PurchaseDeleteLog_Counter] FOREIGN KEY([CounterId])
REFERENCES [dbo].[Counter] ([Id])
GO
ALTER TABLE [dbo].[PurchaseDeleteLog] CHECK CONSTRAINT [FK_PurchaseDeleteLog_Counter]
GO
ALTER TABLE [dbo].[PurchaseDeleteLog]  WITH CHECK ADD  CONSTRAINT [FK_PurchaseDeleteLog_MainPurchase] FOREIGN KEY([MainPurchaseId])
REFERENCES [dbo].[MainPurchase] ([Id])
GO
ALTER TABLE [dbo].[PurchaseDeleteLog] CHECK CONSTRAINT [FK_PurchaseDeleteLog_MainPurchase]
GO
ALTER TABLE [dbo].[PurchaseDeleteLog]  WITH CHECK ADD  CONSTRAINT [FK_PurchaseDeleteLog_PurchaseDetail] FOREIGN KEY([PurchaseDetailId])
REFERENCES [dbo].[PurchaseDetail] ([Id])
GO
ALTER TABLE [dbo].[PurchaseDeleteLog] CHECK CONSTRAINT [FK_PurchaseDeleteLog_PurchaseDetail]
GO
ALTER TABLE [dbo].[PurchaseDeleteLog]  WITH CHECK ADD  CONSTRAINT [FK_PurchaseDeleteLog_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[PurchaseDeleteLog] CHECK CONSTRAINT [FK_PurchaseDeleteLog_User]
GO
ALTER TABLE [dbo].[PurchaseDetail]  WITH CHECK ADD  CONSTRAINT [FK_PurchaseDetail_MainPurchase] FOREIGN KEY([MainPurchaseId])
REFERENCES [dbo].[MainPurchase] ([Id])
GO
ALTER TABLE [dbo].[PurchaseDetail] CHECK CONSTRAINT [FK_PurchaseDetail_MainPurchase]
GO
ALTER TABLE [dbo].[PurchaseDetail]  WITH CHECK ADD  CONSTRAINT [FK_PurchaseDetail_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[PurchaseDetail] CHECK CONSTRAINT [FK_PurchaseDetail_Product]
GO
ALTER TABLE [dbo].[PurchaseDetailInTransaction]  WITH CHECK ADD  CONSTRAINT [FK_PurchaseDetailInTransaction_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[PurchaseDetailInTransaction] CHECK CONSTRAINT [FK_PurchaseDetailInTransaction_Product]
GO
ALTER TABLE [dbo].[PurchaseDetailInTransaction]  WITH CHECK ADD  CONSTRAINT [FK_PurchaseDetailInTransaction_PurchaseDetail] FOREIGN KEY([PurchaseDetailId])
REFERENCES [dbo].[PurchaseDetail] ([Id])
GO
ALTER TABLE [dbo].[PurchaseDetailInTransaction] CHECK CONSTRAINT [FK_PurchaseDetailInTransaction_PurchaseDetail]
GO
ALTER TABLE [dbo].[PurchaseDetailInTransaction]  WITH CHECK ADD  CONSTRAINT [FK_PurchaseDetailInTransaction_TransactionDetail] FOREIGN KEY([TransactionDetailId])
REFERENCES [dbo].[TransactionDetail] ([Id])
GO
ALTER TABLE [dbo].[PurchaseDetailInTransaction] CHECK CONSTRAINT [FK_PurchaseDetailInTransaction_TransactionDetail]
GO
ALTER TABLE [dbo].[RoleManagement]  WITH CHECK ADD  CONSTRAINT [FK_RoleManagement_UserRole] FOREIGN KEY([UserRoleId])
REFERENCES [dbo].[UserRole] ([Id])
GO
ALTER TABLE [dbo].[RoleManagement] CHECK CONSTRAINT [FK_RoleManagement_UserRole]
GO
ALTER TABLE [dbo].[Shop]  WITH CHECK ADD  CONSTRAINT [FK_Shop_City] FOREIGN KEY([CityId])
REFERENCES [dbo].[City] ([Id])
GO
ALTER TABLE [dbo].[Shop] CHECK CONSTRAINT [FK_Shop_City]
GO
ALTER TABLE [dbo].[SPDetail]  WITH CHECK ADD  CONSTRAINT [FK_SPDetail_Product] FOREIGN KEY([ParentProductID])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[SPDetail] CHECK CONSTRAINT [FK_SPDetail_Product]
GO
ALTER TABLE [dbo].[SPDetail]  WITH CHECK ADD  CONSTRAINT [FK_SPDetail_Product1] FOREIGN KEY([ChildProductID])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[SPDetail] CHECK CONSTRAINT [FK_SPDetail_Product1]
GO
ALTER TABLE [dbo].[SPDetail]  WITH CHECK ADD  CONSTRAINT [FK_SPDetail_TransactionDetail] FOREIGN KEY([TransactionDetailID])
REFERENCES [dbo].[TransactionDetail] ([Id])
GO
ALTER TABLE [dbo].[SPDetail] CHECK CONSTRAINT [FK_SPDetail_TransactionDetail]
GO
ALTER TABLE [dbo].[StockInDetail]  WITH CHECK ADD  CONSTRAINT [FK_StockInDetail_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[StockInDetail] CHECK CONSTRAINT [FK_StockInDetail_Product]
GO
ALTER TABLE [dbo].[StockInDetail]  WITH CHECK ADD  CONSTRAINT [FK_StockInDetail_StockInHeader] FOREIGN KEY([StockInHeaderId])
REFERENCES [dbo].[StockInHeader] ([id])
GO
ALTER TABLE [dbo].[StockInDetail] CHECK CONSTRAINT [FK_StockInDetail_StockInHeader]
GO
ALTER TABLE [dbo].[StockInHeader]  WITH CHECK ADD  CONSTRAINT [FK_StockInHeader_Shop] FOREIGN KEY([FromShopId])
REFERENCES [dbo].[Shop] ([Id])
GO
ALTER TABLE [dbo].[StockInHeader] CHECK CONSTRAINT [FK_StockInHeader_Shop]
GO
ALTER TABLE [dbo].[StockInHeader]  WITH CHECK ADD  CONSTRAINT [FK_StockInHeader_Shop1] FOREIGN KEY([ToShopId])
REFERENCES [dbo].[Shop] ([Id])
GO
ALTER TABLE [dbo].[StockInHeader] CHECK CONSTRAINT [FK_StockInHeader_Shop1]
GO
ALTER TABLE [dbo].[StockInHeader]  WITH CHECK ADD  CONSTRAINT [FK_StockInHeader_User] FOREIGN KEY([UpdatedUser])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[StockInHeader] CHECK CONSTRAINT [FK_StockInHeader_User]
GO
ALTER TABLE [dbo].[StockInHeader]  WITH CHECK ADD  CONSTRAINT [FK_StockInHeader_User1] FOREIGN KEY([CreatedUser])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[StockInHeader] CHECK CONSTRAINT [FK_StockInHeader_User1]
GO
ALTER TABLE [dbo].[StockTransaction]  WITH CHECK ADD  CONSTRAINT [FK_StockTransaction_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[StockTransaction] CHECK CONSTRAINT [FK_StockTransaction_Product]
GO
ALTER TABLE [dbo].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_TransactionDetail] FOREIGN KEY([TransactionDetailId])
REFERENCES [dbo].[TransactionDetail] ([Id])
GO
ALTER TABLE [dbo].[Ticket] CHECK CONSTRAINT [FK_Ticket_TransactionDetail]
GO
ALTER TABLE [dbo].[TicketButtonAssign]  WITH CHECK ADD  CONSTRAINT [FK_TicketButtonAssign_Product] FOREIGN KEY([Assignproductid])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[TicketButtonAssign] CHECK CONSTRAINT [FK_TicketButtonAssign_Product]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_Counter] FOREIGN KEY([CounterId])
REFERENCES [dbo].[Counter] ([Id])
GO
ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_Counter]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_Currency] FOREIGN KEY([ReceivedCurrencyId])
REFERENCES [dbo].[Currency] ([Id])
GO
ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_Currency]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_Customer] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_Customer]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_GiftCard] FOREIGN KEY([GiftCardId])
REFERENCES [dbo].[GiftCard] ([Id])
GO
ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_GiftCard]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_PaymentType] FOREIGN KEY([PaymentTypeId])
REFERENCES [dbo].[PaymentType] ([Id])
GO
ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_PaymentType]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_transaction_Shop] FOREIGN KEY([ShopId])
REFERENCES [dbo].[Shop] ([Id])
GO
ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_transaction_Shop]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_Transaction] FOREIGN KEY([ParentId])
REFERENCES [dbo].[Transaction] ([Id])
GO
ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_Transaction]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_User]
GO
ALTER TABLE [dbo].[TransactionDetail]  WITH CHECK ADD  CONSTRAINT [FK_TransactionDetail_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[TransactionDetail] CHECK CONSTRAINT [FK_TransactionDetail_Product]
GO
ALTER TABLE [dbo].[TransactionDetail]  WITH CHECK ADD  CONSTRAINT [FK_TransactionDetail_Transaction] FOREIGN KEY([TransactionId])
REFERENCES [dbo].[Transaction] ([Id])
GO
ALTER TABLE [dbo].[TransactionDetail] CHECK CONSTRAINT [FK_TransactionDetail_Transaction]
GO
ALTER TABLE [dbo].[Turnstile]  WITH CHECK ADD  CONSTRAINT [FK_Turnstile_TurnStileServer] FOREIGN KEY([ServerID])
REFERENCES [dbo].[TurnStileServer] ([Id])
GO
ALTER TABLE [dbo].[Turnstile] CHECK CONSTRAINT [FK_Turnstile_TurnStileServer]
GO
ALTER TABLE [dbo].[UsePrePaidDebt]  WITH CHECK ADD  CONSTRAINT [FK_UsePrePaidDebt_Counter] FOREIGN KEY([CounterId])
REFERENCES [dbo].[Counter] ([Id])
GO
ALTER TABLE [dbo].[UsePrePaidDebt] CHECK CONSTRAINT [FK_UsePrePaidDebt_Counter]
GO
ALTER TABLE [dbo].[UsePrePaidDebt]  WITH CHECK ADD  CONSTRAINT [FK_UsePrePaidDebt_Transaction] FOREIGN KEY([CreditTransactionId])
REFERENCES [dbo].[Transaction] ([Id])
GO
ALTER TABLE [dbo].[UsePrePaidDebt] CHECK CONSTRAINT [FK_UsePrePaidDebt_Transaction]
GO
ALTER TABLE [dbo].[UsePrePaidDebt]  WITH CHECK ADD  CONSTRAINT [FK_UsePrePaidDebt_Transaction1] FOREIGN KEY([PrePaidDebtTransactionId])
REFERENCES [dbo].[Transaction] ([Id])
GO
ALTER TABLE [dbo].[UsePrePaidDebt] CHECK CONSTRAINT [FK_UsePrePaidDebt_Transaction1]
GO
ALTER TABLE [dbo].[UsePrePaidDebt]  WITH CHECK ADD  CONSTRAINT [FK_UsePrePaidDebt_User] FOREIGN KEY([CashierId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UsePrePaidDebt] CHECK CONSTRAINT [FK_UsePrePaidDebt_User]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_User] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_User]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_User1] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_User1]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_UserRole] FOREIGN KEY([UserRoleId])
REFERENCES [dbo].[UserRole] ([Id])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_UserRole]
GO
ALTER TABLE [dbo].[WrapperItem]  WITH CHECK ADD  CONSTRAINT [FK_WrapperItem_Product] FOREIGN KEY([ParentProductId])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[WrapperItem] CHECK CONSTRAINT [FK_WrapperItem_Product]
GO
ALTER TABLE [dbo].[WrapperItem]  WITH CHECK ADD  CONSTRAINT [FK_WrapperItem_Product1] FOREIGN KEY([ChildProductId])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[WrapperItem] CHECK CONSTRAINT [FK_WrapperItem_Product1]
GO
/****** Object:  StoredProcedure [dbo].[AverageMonthlySaleReport]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[AverageMonthlySaleReport]
@Year Datetime,
@ProductId bigint
as
begin


Declare  @MonthlySale Table (SaleDate datetime,ProductId bigint, Qty int,TotalAmount bigint)

Insert Into @MonthlySale

select CAST(t.DateTime as date) as SaleDate,pd.Id as ProductId ,Sum(td.Qty) as Qty, Sum( (td.Qty*td.UnitPrice)) as TotalAmount   from Product as pd 

inner join TransactionDetail as td  on td.ProductId=pd.Id

inner join [Transaction] as t on t.Id=td.TransactionId

inner join Unit as u on u.Id=pd.UnitId

where

pd.Id=@ProductId and YEAR(t.DateTime)=YEAR(@Year) and t.IsDeleted=0 and td.IsDeleted =0 and t.IsComplete=1

group by pd.Id,CAST(t.DateTime as date)


Select MONTH(SaleDate) as SaleMonth,ProductId,SUM(Qty) as TotalQty,SUM(TotalAmount) as TotalAmount  from @MonthlySale

Group by MONTH(SaleDate),ProductId

end






































GO
/****** Object:  StoredProcedure [dbo].[AverageMonthlySaleReportBrandId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[AverageMonthlySaleReportBrandId]
@Year Datetime,
@BrandId int,
@currentshortcode varchar(2)
as
begin

Declare  @MonthlySale Table (SaleDate datetime,ProductId bigint,Name nvarchar(200),ProductCode nvarchar(200),ProductUnit nvarchar(50),Price bigint, Qty int,TotalAmount bigint)

Insert Into @MonthlySale

			select CAST(t.DateTime as date) as SaleDate,pd.Id as ProductId,pd.Name as Name,pd.ProductCode,u.UnitName as ProductUnit,pd.Price ,Sum(td.Qty) as Qty, Sum( (td.Qty*td.UnitPrice)) as TotalAmount   from Product as pd 

			inner join TransactionDetail as td  on td.ProductId=pd.Id

			inner join [Transaction] as t on t.Id=td.TransactionId

			inner join Unit as u on u.Id=pd.UnitId

			where 						
			pd.BrandId=@BrandId  and YEAR(t.DateTime)=YEAR(@Year) and t.IsDeleted=0 and td.IsDeleted =0 and t.IsComplete=1
			 and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))


			group by pd.Id,CAST(t.DateTime as date),pd.Name,pd.ProductCode,u.UnitName,pd.Price
			
		

Declare  @TotalAmount Table (TotalAmount int,TotalQty float,PId bigint,PCode nvarchar(200))
Insert Into @TotalAmount
select SUM(TotalAmount)AS TotalAmount,SUM(Qty) AS Qty,ProductId,ProductCode from @MonthlySale Group BY ProductId,ProductCode

--select * from @TotalAmount
--order by PId


Declare  @MonthlySalebymonth Table (PName nvarchar(200),PId bigint,PUnit nvarchar(50),Price bigint,Jan int,Feb int,Mar int,Apr int,May int,Jun int,July int,Aug int,Sep int,Oct int,Nov int,Dece int)
Insert Into @MonthlySalebymonth
select *
from
(
  select Name,ProductId,ProductUnit,Price,DATENAME(month, SaleDate) AS SaleMonth,
    ISNULL(Qty,0) as Qty
  from @MonthlySale


) src
pivot
(
  sum(Qty)
  for SaleMonth in (January,February,March,April,May,June,July,August,September,October,November,December)
) piv;



SELECT t1.PName,t2.PCode,t1.PId,t1.PUnit,t1.Price,ISNULL(t1.Jan,0) AS January ,ISNULL(t1.Feb,0) AS February,ISNULL(t1.Mar,0) AS March,ISNULL(t1.Apr,0) AS April,ISNULL(t1.May,0) AS May,ISNULL(t1.Jun,0) AS June,
ISNULL(t1.July,0) AS July,ISNULL(t1.Aug,0) AS August ,ISNULL(t1.Sep,0) AS September,ISNULL(t1.Oct,0) AS October,ISNULL(t1.Nov,0) AS November,ISNULL(t1.Dece,0) AS December,t2.TotalQty,CAST(t2.TotalQty / 12 AS DECIMAL(18,2)) AS AvgQty,t2.TotalAmount 
FROM @MonthlySalebymonth t1,@TotalAmount t2
WHERE t1.PId=t2.PId
Order by t1.PId


end

GO
/****** Object:  StoredProcedure [dbo].[AverageMonthlySaleReportByBrandIdAndCounterId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[AverageMonthlySaleReportByBrandIdAndCounterId]
@Year Datetime,
@BrandId int,
@CounterId int,
@currentshortcode varchar(2)
as
begin

Declare  @MonthlySale Table (SaleDate datetime,ProductId bigint,Name nvarchar(200),ProductCode nvarchar(200),ProductUnit nvarchar(50),Price bigint, Qty int,TotalAmount bigint)

Insert Into @MonthlySale

			select CAST(t.DateTime as date) as SaleDate,pd.Id as ProductId,pd.Name as Name,pd.ProductCode,u.UnitName as ProductUnit,pd.Price ,Sum(td.Qty) as Qty, Sum( (td.Qty*td.UnitPrice)) as TotalAmount   from Product as pd 

			inner join TransactionDetail as td  on td.ProductId=pd.Id

			inner join [Transaction] as t on t.Id=td.TransactionId

			inner join Unit as u on u.Id=pd.UnitId

			where 						
			t.CounterId=@CounterId and pd.BrandId=@BrandId  and YEAR(t.DateTime)=YEAR(@Year) and t.IsDeleted=0 and td.IsDeleted =0 and t.IsComplete=1
			 and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))


			group by pd.Id,CAST(t.DateTime as date),pd.Name,pd.ProductCode,u.UnitName,pd.Price
			
		

Declare  @TotalAmount Table (TotalAmount int,TotalQty float,PId bigint,PCode nvarchar(200))
Insert Into @TotalAmount
select SUM(TotalAmount)AS TotalAmount,SUM(Qty) AS Qty,ProductId,ProductCode from @MonthlySale Group BY ProductId,ProductCode

--select * from @TotalAmount
--order by PId


Declare  @MonthlySalebymonth Table (PName nvarchar(200),PId bigint,PUnit nvarchar(50),Price bigint,Jan int,Feb int,Mar int,Apr int,May int,Jun int,July int,Aug int,Sep int,Oct int,Nov int,Dece int)
Insert Into @MonthlySalebymonth
select *
from
(
  select Name,ProductId,ProductUnit,Price,DATENAME(month, SaleDate) AS SaleMonth,
    ISNULL(Qty,0) as Qty
  from @MonthlySale


) src
pivot
(
  sum(Qty)
  for SaleMonth in (January,February,March,April,May,June,July,August,September,October,November,December)
) piv;



SELECT t1.PName,t2.PCode,t1.PId,t1.PUnit,t1.Price,ISNULL(t1.Jan,0) AS January ,ISNULL(t1.Feb,0) AS February,ISNULL(t1.Mar,0) AS March,ISNULL(t1.Apr,0) AS April,ISNULL(t1.May,0) AS May,ISNULL(t1.Jun,0) AS June,
ISNULL(t1.July,0) AS July,ISNULL(t1.Aug,0) AS August ,ISNULL(t1.Sep,0) AS September,ISNULL(t1.Oct,0) AS October,ISNULL(t1.Nov,0) AS November,ISNULL(t1.Dece,0) AS December,t2.TotalQty,CAST(t2.TotalQty / 12 AS DECIMAL(18,2)) AS AvgQty,t2.TotalAmount 
FROM @MonthlySalebymonth t1,@TotalAmount t2
WHERE t1.PId=t2.PId
Order by t1.PId


end

GO
/****** Object:  StoredProcedure [dbo].[AverageMonthlySaleReportByDateTime]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[AverageMonthlySaleReportByDateTime]

@Year Datetime,
@currentshortcode varchar(2)

as

begin



Declare  @MonthlySale Table (SaleDate datetime,ProductId bigint,Name nvarchar(200),ProductCode nvarchar(200),ProductUnit nvarchar(50),Price bigint, Qty int,TotalAmount bigint)



Insert Into @MonthlySale



			select CAST(t.DateTime as date) as SaleDate,pd.Id as ProductId,pd.Name as Name,pd.ProductCode,u.UnitName as ProductUnit,pd.Price ,Sum(td.Qty) as Qty, Sum( (td.Qty*td.UnitPrice)) as TotalAmount   from Product as pd 



			inner join TransactionDetail as td  on td.ProductId=pd.Id



			inner join [Transaction] as t on t.Id=td.TransactionId



			inner join Unit as u on u.Id=pd.UnitId



			where 						

			 YEAR(t.DateTime)=YEAR(@Year)  and     t.IsDeleted=0 and td.IsDeleted =0 and t.IsComplete=1
			  and (T.Type = 'Sale' or T.Type = 'Credit' or T.Type = 'GiftCard') 
			  and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))


			group by pd.Id,CAST(t.DateTime as date),pd.Name,pd.ProductCode,u.UnitName,pd.Price

			

		



Declare  @TotalAmount Table (TotalAmount int,TotalQty float,PId bigint,PCode nvarchar(200))

Insert Into @TotalAmount

select SUM(TotalAmount)AS TotalAmount,SUM(Qty) AS Qty,ProductId,ProductCode from @MonthlySale Group BY ProductId,ProductCode



--select * from @TotalAmount

--order by PId





Declare  @MonthlySalebymonth Table (PName nvarchar(200),PId bigint,PUnit nvarchar(50),Price bigint,Jan int,Feb int,Mar int,Apr int,May int,Jun int,July int,Aug int,Sep int,Oct int,Nov int,Dece int)

Insert Into @MonthlySalebymonth

select *

from

(

  select Name,ProductId,ProductUnit,Price,DATENAME(month, SaleDate) AS SaleMonth,

    ISNULL(Qty,0) as Qty

  from @MonthlySale





) src

pivot

(

  sum(Qty)

  for SaleMonth in (January,February,March,April,May,June,July,August,September,October,November,December)

) piv;







SELECT t1.PName,t2.PCode,t1.PId,t1.PUnit,t1.Price,ISNULL(t1.Jan,0) AS January ,ISNULL(t1.Feb,0) AS February,ISNULL(t1.Mar,0) AS March,ISNULL(t1.Apr,0) AS April,ISNULL(t1.May,0) AS May,ISNULL(t1.Jun,0) AS June,

ISNULL(t1.July,0) AS July,ISNULL(t1.Aug,0) AS August ,ISNULL(t1.Sep,0) AS September,ISNULL(t1.Oct,0) AS October,ISNULL(t1.Nov,0) AS November,ISNULL(t1.Dece,0) AS December,t2.TotalQty,CAST(t2.TotalQty / 12 AS DECIMAL(18,2)) AS AvgQty,t2.TotalAmount 

FROM @MonthlySalebymonth t1,@TotalAmount t2

WHERE t1.PId=t2.PId

Order by t1.PId





end

GO
/****** Object:  StoredProcedure [dbo].[AverageMonthlySaleReportCounterId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[AverageMonthlySaleReportCounterId]
@Year Datetime,
@CounterId int,
@currentshortcode varchar(2)
as
begin

Declare  @MonthlySale Table (SaleDate datetime,ProductId bigint,Name nvarchar(200),ProductCode nvarchar(200),ProductUnit nvarchar(50),Price bigint, Qty int,TotalAmount bigint)

Insert Into @MonthlySale

			select CAST(t.DateTime as date) as SaleDate,pd.Id as ProductId,pd.Name as Name,pd.ProductCode,u.UnitName as ProductUnit,pd.Price ,Sum(td.Qty) as Qty, Sum( (td.Qty*td.UnitPrice)) as TotalAmount   from Product as pd 

			inner join TransactionDetail as td  on td.ProductId=pd.Id

			inner join [Transaction] as t on t.Id=td.TransactionId

			inner join Unit as u on u.Id=pd.UnitId

			where 						
			t.CounterId=@CounterId and YEAR(t.DateTime)=YEAR(@Year)  and (T.PaymentTypeId != 4 and T.PaymentTypeId != 6)  and   (T.Type = 'Sale' or T.Type = 'Credit' or T.Type = 'GiftCard') and t.IsDeleted=0 
			 and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))

			--and t.IsComplete=1 or  td.IsDeleted is null 

			group by pd.Id,CAST(t.DateTime as date),pd.Name,pd.ProductCode,u.UnitName,pd.Price
			
		

Declare  @TotalAmount Table (TotalAmount int,TotalQty float,PId bigint,PCode nvarchar(200))
Insert Into @TotalAmount
select SUM(TotalAmount)AS TotalAmount,SUM(Qty) AS Qty,ProductId,ProductCode from @MonthlySale Group BY ProductId,ProductCode

--select * from @TotalAmount
--order by PId


Declare  @MonthlySalebymonth Table (PName nvarchar(200),PId bigint,PUnit nvarchar(50),Price bigint,Jan int,Feb int,Mar int,Apr int,May int,Jun int,July int,Aug int,Sep int,Oct int,Nov int,Dece int)
Insert Into @MonthlySalebymonth
select *
from
(
  select Name,ProductId,ProductUnit,Price,DATENAME(month, SaleDate) AS SaleMonth,
    ISNULL(Qty,0) as Qty
  from @MonthlySale


) src
pivot
(
  sum(Qty)
  for SaleMonth in (January,February,March,April,May,June,July,August,September,October,November,December)
) piv;



SELECT t1.PName,t2.PCode,t1.PId,t1.PUnit,t1.Price,ISNULL(t1.Jan,0) AS January ,ISNULL(t1.Feb,0) AS February,ISNULL(t1.Mar,0) AS March,ISNULL(t1.Apr,0) AS April,ISNULL(t1.May,0) AS May,ISNULL(t1.Jun,0) AS June,
ISNULL(t1.July,0) AS July,ISNULL(t1.Aug,0) AS August ,ISNULL(t1.Sep,0) AS September,ISNULL(t1.Oct,0) AS October,ISNULL(t1.Nov,0) AS November,ISNULL(t1.Dece,0) AS December,t2.TotalQty,CAST(t2.TotalQty / 12 AS DECIMAL(18,2)) AS AvgQty,t2.TotalAmount 
FROM @MonthlySalebymonth t1,@TotalAmount t2
WHERE t1.PId=t2.PId
Order by t1.PId


end

GO
/****** Object:  StoredProcedure [dbo].[ClearDBConnections]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ClearDBConnections]
AS
BEGIN
	
ALTER DATABASE mPOSV3
SET OFFLINE WITH ROLLBACK IMMEDIATE
ALTER DATABASE mPOSV3
SET ONLINE

END











GO
/****** Object:  StoredProcedure [dbo].[CustomerAutoID]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CustomerAutoID]
       @IssueDate datetime
      ,@ShopCode varchar(5)
AS
BEGIN
		
	DECLARE @NEWID VARCHAR(20);		
	SELECT @NEWID = ('Cu' + @ShopCode + replicate('0', 6 - len(CONVERT(VARCHAR,N.OID + 1))) +
    CONVERT(VARCHAR,N.OID + 1)) FROM (
    SELECT CASE WHEN MAX(T.TID) IS null then 0 else MAX(T.TID) end as OID FROM (
    SELECT SUBSTRING(CustomerCode, 5, LEN(CustomerCode)) as TID FROM [Customer] Where SUBSTRING(CustomerCode,0,3) = 'Cu'
	 And SUBSTRING(CustomerCode,3,2) = @ShopCode
) AS T 
) AS N
Select @NEWID
END














GO
/****** Object:  StoredProcedure [dbo].[ExportDatabase]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ExportDatabase]
	@Path varchar(Max),
	@BackUpName varchar(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    BACKUP DATABASE POS TO  DISK = @Path WITH NOFORMAT, NOINIT,  NAME = @BackUpName, SKIP, NOREWIND, NOUNLOAD,  STATS = 10

END






































GO
/****** Object:  StoredProcedure [dbo].[GetConsignmentProduct]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[GetConsignmentProduct]    
@fromdate datetime,    
@todate datetime,    
@cId int    
    
    
as    
BEGIN    
    
if(@cId=0)    
begin    
   
select distinct pd.Id As ProductId,pd.Name,td.UnitPrice,con.Name as [Counter Name],td.IsDeleted,td.DiscountRate,td.TaxRate, td.ConsignmentPrice ,sum(td.Qty) Qty
from TransactionDetail as td     
inner join Product as pd on td.ProductId=pd.Id  inner join    
 [Transaction] as t on td.TransactionId= t.Id inner join ConsignmentCounter as con on pd.ConsignmentCounterId=con.Id    
 where pd.IsConsignment=1 and  CAST(t.DateTime as Date) >=CAST(@fromdate as Date)    
  and CAST(t.DateTime as Date)<=CAST(@todate as Date)
  and t.Type not in ('Refund','CreditRefund')
    group by pd.Id,pd.Name,td.UnitPrice,con.Name,td.IsDeleted,td.DiscountRate,td.TaxRate,td.ConsignmentPrice
    
end    
    
else    
begin    
select distinct pd.Id As ProductId,
 pd.Name,td.UnitPrice,td.IsDeleted,con.Name as [Counter Name],td.DiscountRate,
 td.TaxRate,td.ConsignmentPrice, SUM(td.Qty) Qty
  from TransactionDetail as td inner join Product as pd on td.ProductId=pd.Id 
   inner join    
 [Transaction] as t on td.TransactionId= t.Id
  inner join ConsignmentCounter as con on pd.ConsignmentCounterId=con.Id    
 where pd.IsConsignment=1 and pd.ConsignmentCounterId=@cId     
 and  CAST(t.DateTime as Date) >=CAST(@fromdate as Date) 
 and CAST(t.DateTime as Date)<=CAST(@todate as Date)      
  and t.Type not in ('Refund','CreditRefund')
     group by pd.Id,pd.Name,td.UnitPrice,con.Name,td.IsDeleted,td.DiscountRate,td.TaxRate,td.ConsignmentPrice
	
 end   

END

























GO
/****** Object:  StoredProcedure [dbo].[GetCustomerCode]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[GetCustomerCode]
@prefix  varchar(20),
@TotalNumberlength int,
@PrefixLength int
as
begin
	DECLARE @NEWID VARCHAR(10);		
	SELECT @NEWID = (@prefix + replicate('0',@TotalNumberlength - len(CONVERT(VARCHAR,N.OID + 1))) +
CONVERT(VARCHAR,N.OID + 1)) FROM (
SELECT CASE WHEN MAX(T.TID) IS null then 0 else MAX(T.TID) end as OID FROM (
SELECT SUBSTRING(CustomerCode,@PrefixLength, LEN(CustomerCode)) as TID FROM Customer Where SUBSTRING(CustomerCode,0,@PrefixLength) = @prefix
) AS T 
) AS N
Select @NEWID

End
















GO
/****** Object:  StoredProcedure [dbo].[GetCustomerSaleByCuId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[GetCustomerSaleByCuId]
@Id int
as
begin

select cu.Name as [Customer Name],p.Name as [Product Name],p.Qty,p.Price,(p.Qty*p.Price) as [Total Amount] from  Customer as cu left join [Transaction] as t on t.CustomerId = cu.Id


left join TransactionDetail as td on td.TransactionId=t.Id 


left join Product as p on p.Id=td.ProductId  where cu.Id=@Id
end






































GO
/****** Object:  StoredProcedure [dbo].[GetCustomerSaleById]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[GetCustomerSaleById]

@CustomerId int,

@ProductId int,

@fromdate datetime,

@todate datetime,

 @currentshortcode varchar(2)

as

begin





begin
select * from
(
select t.Id as TransactionId,t.DateTime as SaleDate,t.MCDiscountPercent as mcDiscount,

case when (t.MCDiscountAmt > 0) then  ( (td.UnitPrice * td.Qty) * t.MCDiscountPercent/100) when (t.BDDiscountAmt > 0) 
then ((td.UnitPrice * td.Qty) * t.BDDiscountAmt/100) else 0 end as MemberDiscount,

case when (t.MemberTypeId=0 or t.MemberTypeId = null) then 'Normal'
else m.Name end as MemberType,

cu.Name as [Customer Name],p.Name as [Product Name],td.productId As ProudctId,(td.Qty) AS TotalSaleQty,  
--for refund delete case
case when( ( select count (*) from TransactionDetail as tds  where tds.TransactionId =t.ParentId and tds.ProductId = td.ProductId and tds.IsDeleted=1) >0 or (select sum(tds.qty) from TransactionDetail tds where tds.TransactionId =t.ParentId and tds.ProductId = td.ProductId) is null)

 then 0
 --only sale no refund case
  when ((t.ParentId is null))
 then 0

 --refund  case
 else 
 
 (select sum(tds.qty) from TransactionDetail tds where tds.TransactionId =t.ParentId and tds.ProductId = td.ProductId and tds.IsDeleted=0 ) end As RefundQty,

 (td.Qty -
  --for refund delete case
case when( ( select count (*) from TransactionDetail as tds  where tds.TransactionId =t.ParentId and tds.ProductId = td.ProductId and tds.IsDeleted=1) >0 or (select sum(tds.qty) from TransactionDetail tds where tds.TransactionId =t.ParentId and tds.ProductId = td.ProductId) is null)

 then 0
 --only sale no refund case
  when ((t.ParentId is null))
 then 0

 --refund  case
 else 
 
 (select sum(tds.qty) from TransactionDetail tds where tds.TransactionId =t.ParentId and tds.ProductId = td.ProductId and tds.IsDeleted=0 )end  )  as ActualSalQty

,(td.SellingPrice) As UnitPrice,


  case  when (TD.IsFOC=1 and t.PaymentTypeId!=6) then 'FOC'
   when (TD.IsFOC=1 and t.PaymentTypeId =6) then 'Tester' 
   else '' end as Remark, t.ParentId 
  from  Customer   as cu 

 inner join [Transaction] as t on t.CustomerId = cu.Id 

inner join TransactionDetail as td on td.TransactionId=t.Id 

inner join Product as p on p.Id=td.ProductId     

left join MemberType as m on m.Id=t.MemberTypeId

where td.IsDeleted =0 and t.IsDeleted=0

and t.IsComplete=1



and t.Type not in ('Refund', 'CreditRefund')

and  CAST(T.DateTime as date) >= CAST(@fromDate as date)

 and CAST(T.DateTime as date) <= CAST(@toDate as date)  

 and ((@CustomerId = 0 and  1=1) or (@CustomerId != 0 and t.CustomerId =@CustomerId))

 and ((@ProductId = 0 and 1=1) or (@ProductId != 0 and td.ProductId = @ProductId))

and  ((@currentshortcode ='' and 1=1) or (@currentshortcode <> '' and SUBSTRING(T.Id,3,2)=@currentshortcode))

 --and SUBSTRING(T.Id,3,2)=@currentshortcode
 ) A
 Where RefundQty <> TotalSaleQty
 order by A.SaleDate asc,A.[Customer Name], A.TransactionId,a.[Product Name]

 end



end













GO
/****** Object:  StoredProcedure [dbo].[GetGWPSetQtyAndAmount]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetGWPSetQtyAndAmount]
	@customerType int,
	@fromDate datetime,
	@toDate datetime,
	@CounterId int
AS
BEGIN
	select g.Id,
	 g.Name, 
	 dbo.GetGWPGiftSetQty(g.Id,@customerType,@fromDate,@toDate,@CounterId) as Qty, 
	dbo.GetGWPGiftSetInvoiceAmount(g.Id,@customerType,@fromDate,@toDate,@CounterId) as Amount
	from GiftSystem as g
	where  ((CAST(@fromDate as date) <= CAST(g.ValidFrom as date) 
	and CAST(@toDate as date) >= CAST(g.ValidFrom as date)) or (CAST(g.ValidFrom as date) <= CAST( @fromDate as date) 
	and CAST(g.ValidTo as date) >= CAST(@fromDate as date))) and G.IsActive = 1 and 
	CAST(@fromDate as date)<= CAST(@toDate as date)
END



GO
/****** Object:  StoredProcedure [dbo].[GetGWPTransactions]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetGWPTransactions] --1,'2018-04-01','2018-05-31',0
	@customerType int,
	@fromDate datetime,
	@toDate datetime,
	@CounterId int
AS
if(@CounterId=0) 
					Begin
						set nocount on
						set arithabort on 
						select Cus.Name as Name,
						 T.Id as InvoiceNo, 
						 TD.ProductId as productId, 
						 dbo.GetGWPName(TD.ProductId, T.Id) as GiftName, 
						TD.Qty as Qty,
						 TD.DiscountRate as Dis, 
						 TD.TotalAmount as Total
						from [Transaction] as T inner join Customer as Cus on Cus.Id = T.CustomerId
						inner join TransactionDetail as TD on TD.TransactionId = T.Id					
						where (T.Type = 'Sale' or T.Type = 'Credit') 
						and CAST(T.DateTime as date) >= CAST(@fromDate as date) 
						and CAST(T.DateTime as date) <= CAST(@toDate as date) 
						and T.IsDeleted = 0 and TD.IsDeleted = 0 
					end
else 
 Begin
						set nocount on
						set arithabort on 
						select Cus.Name as Name,
						 T.Id as InvoiceNo, 
						 TD.ProductId as productId, 
						 dbo.GetGWPName(TD.ProductId, T.Id) as GiftName, 
						TD.Qty as Qty,
						 TD.DiscountRate as Dis, 
						 TD.TotalAmount as Total
						from [Transaction] as T inner join Customer as Cus on Cus.Id = T.CustomerId
						inner join TransactionDetail as TD on TD.TransactionId = T.Id					
						where (T.Type = 'Sale' or T.Type = 'Credit') 
						and CAST(T.DateTime as date) >= CAST(@fromDate as date) 
						and CAST(T.DateTime as date) <= CAST(@toDate as date) 
						and T.IsDeleted = 0 and TD.IsDeleted = 0 
						and t.CounterId=@CounterId
						--and Cus.MemberTypeID=@customerType
					end



GO
/****** Object:  StoredProcedure [dbo].[GetNoveliesSaleByCTypte]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[GetNoveliesSaleByCTypte]
@Type nvarchar(50),
@BrandId int,
@ValidFrom DateTime,
@ValidTo DateTime,
@CityId int,
@CounterId int
as
begin
if(@Type='ALL')
select pd.ProductCode,pd.Name,td.UnitPrice,Sum(td.Qty) as TotalQty, Sum(td.TotalAmount) as TotalAmount from NoveltySystem as nv 
inner join ProductInNovelty as pin on pin.NoveltySystemId=nv.Id
left join [TransactionDetail] as td on td.ProductId=pin.ProductId
inner join Product as pd on td.ProductId=pd.Id
left join [Transaction] as t on t.Id=td.TransactionId
inner join shop as s on s.Id=t.ShopId
left join Customer as c on c.Id=t.CustomerId
where nv.BrandId=@BrandId and pin.IsDeleted=0
and Cast(t.UpdatedDate As date) between Cast(@ValidFrom as date) and Cast(@ValidTo As date)
and Cast(nv.ValidFrom As date) = Cast(@ValidFrom as date) and Cast(nv.ValidTo As date) = Cast(@ValidTo As date)
and ((@CityId=0 and 1=1) or (@CityId!=0 and s.CityId=@CityId)) and ((@CounterId =0 and 1=1) or (@CounterId !=0 and t.CounterId=@CounterId))


group by (pd.ProductCode),pd.Name,td.UnitPrice

else if(@Type='VIP')
select pd.ProductCode,pd.Name,td.UnitPrice,Sum(td.Qty) as TotalQty, Sum(td.TotalAmount) as TotalAmount from NoveltySystem as nv 
inner join ProductInNovelty as pin on pin.NoveltySystemId=nv.Id
left join [TransactionDetail] as td on td.ProductId=pin.ProductId
inner join Product as pd on td.ProductId=pd.Id
left join [Transaction] as t on t.Id=td.TransactionId
inner join shop as s on s.Id=t.ShopId
left join Customer as c on c.Id=t.CustomerId
where c.CustomerTypeId=1 and nv.BrandId=@BrandId and pin.IsDeleted=0
and Cast(t.UpdatedDate As date) between Cast(@ValidFrom as date) and Cast(@ValidTo As date)
and Cast(nv.ValidFrom As date) = Cast(@ValidFrom as date) and Cast(nv.ValidTo As date) = Cast(@ValidTo As date)
and ((@CityId=0 and 1=1) or (@CityId!=0 and s.CityId=@CityId)) and ((@CounterId =0 and 1=1) or (@CounterId !=0 and t.CounterId=@CounterId))
group by (pd.ProductCode),pd.Name,td.UnitPrice

else if (@Type)='NonVIP'

select pd.ProductCode,pd.Name,td.UnitPrice,Sum(td.Qty) as TotalQty, Sum(td.TotalAmount) as TotalAmount from NoveltySystem as nv 
inner join ProductInNovelty as pin on pin.NoveltySystemId=nv.Id
left join [TransactionDetail] as td on td.ProductId=pin.ProductId
inner join Product as pd on td.ProductId=pd.Id
left join [Transaction] as t on t.Id=td.TransactionId
inner join shop as s on s.Id=t.ShopId
left  join Customer as c on c.Id=t.CustomerId
where c.CustomerTypeId=2 and nv.BrandId=@BrandId and pin.IsDeleted=0
and Cast(t.UpdatedDate As date) between Cast(@ValidFrom as date) and Cast(@ValidTo As date)
and Cast(nv.ValidFrom As date) = Cast(@ValidFrom as date) and Cast(nv.ValidTo As date) = Cast(@ValidTo As date)
and ((@CityId=0 and 1=1) or (@CityId!=0 and s.CityId=@CityId)) and ((@CounterId =0 and 1=1) or (@CounterId !=0 and t.CounterId=@CounterId))


group by (pd.ProductCode),pd.Name,td.UnitPrice

end



GO
/****** Object:  StoredProcedure [dbo].[GetNoveliesSaleByCTypte1]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[GetNoveliesSaleByCTypte1]
@Type nvarchar(50),
@BrandId int,
@ValidFrom DateTime,
@ValidTo DateTime
as
begin
if(@Type='ALL')
select pd.ProductCode,pd.Name,td.UnitPrice,Sum(td.Qty) as TotalQty, Sum(td.TotalAmount) as TotalAmount from NoveltySystem as nv 
inner join ProductInNovelty as pin on pin.NoveltySystemId=nv.Id
left join [TransactionDetail] as td on td.ProductId=pin.ProductId
inner join Product as pd on td.ProductId=pd.Id
left join [Transaction] as t on t.Id=td.TransactionId
left join Customer as c on c.Id=t.CustomerId
where nv.BrandId=@BrandId and Cast(t.UpdatedDate As date) between Cast(@ValidFrom as date) and Cast(@ValidTo As date)


group by (pd.ProductCode),pd.Name,td.UnitPrice

else if(@Type='VIP')
select pd.ProductCode,pd.Name,td.UnitPrice,Sum(td.Qty) as TotalQty, Sum(td.TotalAmount) as TotalAmount from NoveltySystem as nv 
inner join ProductInNovelty as pin on pin.NoveltySystemId=nv.Id
left join [TransactionDetail] as td on td.ProductId=pin.ProductId
inner join Product as pd on td.ProductId=pd.Id
left join [Transaction] as t on t.Id=td.TransactionId
left join Customer as c on c.Id=t.CustomerId
where c.CustomerTypeId=1 and nv.BrandId=@BrandId and Cast(t.UpdatedDate As date) between Cast(@ValidFrom as date) and Cast(@ValidTo As date)
group by (pd.ProductCode),pd.Name,td.UnitPrice

else if (@Type)='NonVIP'

select pd.ProductCode,pd.Name,td.UnitPrice,Sum(td.Qty) as TotalQty, Sum(td.TotalAmount) as TotalAmount from NoveltySystem as nv 
inner join ProductInNovelty as pin on pin.NoveltySystemId=nv.Id
left join [TransactionDetail] as td on td.ProductId=pin.ProductId
inner join Product as pd on td.ProductId=pd.Id
left join [Transaction] as t on t.Id=td.TransactionId
left join Customer as c on c.Id=t.CustomerId
where c.CustomerTypeId=2 and nv.BrandId=@BrandId and Cast(t.UpdatedDate As date) between Cast(@ValidFrom as date) and Cast(@ValidTo As date)


group by (pd.ProductCode),pd.Name,td.UnitPrice

end



GO
/****** Object:  StoredProcedure [dbo].[GetNoveltiesSale]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[GetNoveltiesSale]
as
begin
select nv.BrandId,b.Name from NoveltySystem  as nv inner join Brand as b on b.Id =nv.BrandId  group by nv.BrandId,b.Name
end



GO
/****** Object:  StoredProcedure [dbo].[GetNoveltySaleByBrandId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[GetNoveltySaleByBrandId]
@BrandId int,
@CityId int,
@CounterId int
as
begin

select pd.ProductCode,pd.Name,td.UnitPrice,Sum(td.Qty) as TotalQty, Sum(td.TotalAmount) as TotalAmount from NoveltySystem as nv 
inner join ProductInNovelty as pin on pin.NoveltySystemId=nv.Id
left join [TransactionDetail] as td on td.ProductId=pin.ProductId
inner join Product as pd on td.ProductId=pd.Id
left join [Transaction] as t on t.Id=td.TransactionId
inner join shop as s on s.Id=t.ShopId
left join Customer as c on c.Id=t.CustomerId

where nv.BrandId=@BrandId and pin.IsDeleted=0	and ((@CityId=0 and 1=1) or (@CityId!=0 and s.CityId=@CityId)) and ((@CounterId =0 and 1=1) or (@CounterId !=0 and t.CounterId=@CounterId))
group by (pd.ProductCode),pd.Name,td.UnitPrice




end



GO
/****** Object:  StoredProcedure [dbo].[GetNoveltySaleByBrandId_Result]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[GetNoveltySaleByBrandId_Result]
@BrandId int
as
begin

select pd.ProductCode,pd.Name,td.UnitPrice,Sum(td.Qty) as TotalQty, Sum(td.TotalAmount) as TotalAmount from NoveltySystem as nv 
inner join ProductInNovelty as pin on pin.NoveltySystemId=nv.Id
left join [TransactionDetail] as td on td.ProductId=pin.ProductId
inner join Product as pd on td.ProductId=pd.Id
left join [Transaction] as t on t.Id=td.TransactionId
left join Customer as c on c.Id=t.CustomerId

where nv.BrandId=@BrandId and pin.IsDeleted=0
group by (pd.ProductCode),pd.Name,td.UnitPrice




end



GO
/****** Object:  StoredProcedure [dbo].[GetNoveltySaleByCType_Result]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[GetNoveltySaleByCType_Result]
@Type nvarchar(50)
as
begin
if(@Type='ALL')
select pd.ProductCode,pd.Name,td.UnitPrice,Sum(td.Qty) as TotalQty, Sum(td.TotalAmount) as TotalAmount from NoveltySystem as nv 
inner join ProductInNovelty as pin on pin.NoveltySystemId=nv.Id
left join [TransactionDetail] as td on td.ProductId=pin.ProductId
inner join Product as pd on td.ProductId=pd.Id 
left join [Transaction] as t on t.Id=td.TransactionId
left join Customer as c on c.Id=t.CustomerId



group by (pd.ProductCode),pd.Name,td.UnitPrice

else if(@Type='VIP')
select pd.ProductCode,pd.Name,td.UnitPrice,Sum(td.Qty) as TotalQty, Sum(td.TotalAmount) as TotalAmount from NoveltySystem as nv 
inner join ProductInNovelty as pin on pin.NoveltySystemId=nv.Id
left join [TransactionDetail] as td on td.ProductId=pin.ProductId
inner join Product as pd on td.ProductId=pd.Id
left join [Transaction] as t on t.Id=td.TransactionId
left join Customer as c on c.Id=t.CustomerId
where c.CustomerTypeId=1 
group by (pd.ProductCode),pd.Name,td.UnitPrice

else if (@Type)='NonVIP'

select pd.ProductCode,pd.Name,td.UnitPrice,Sum(td.Qty) as TotalQty, Sum(td.TotalAmount) as TotalAmount from NoveltySystem as nv 
inner join ProductInNovelty as pin on pin.NoveltySystemId=nv.Id
left join [TransactionDetail] as td on td.ProductId=pin.ProductId
inner join Product as pd on td.ProductId=pd.Id
left join [Transaction] as t on t.Id=td.TransactionId
left join Customer as c on c.Id=t.CustomerId
where c.CustomerTypeId=2


group by (pd.ProductCode),pd.Name,td.UnitPrice

end



GO
/****** Object:  StoredProcedure [dbo].[GetNoveltySaleByDate]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[GetNoveltySaleByDate]
@BrandId int,
@FromDate datetime,
@ToDate datetime,
@CityId int,
@CounterId int
as
begin

select pd.ProductCode,pd.Name,td.UnitPrice,Sum(td.Qty) as TotalQty, Sum(td.TotalAmount) as TotalAmount from NoveltySystem as nv 
inner join ProductInNovelty as pin on pin.NoveltySystemId=nv.Id
left join [TransactionDetail] as td on td.ProductId=pin.ProductId
inner join Product as pd on td.ProductId=pd.Id
left join [Transaction] as t on t.Id=td.TransactionId
inner join shop as s on s.Id=t.ShopId
left join Customer as c on c.Id=t.CustomerId

where nv.BrandId=@BrandId and pin.IsDeleted=0 and Cast (nv.ValidFrom as Date)=Cast (@FromDate as Date) and Cast(nv.ValidTo as Date)=Cast( @ToDate as Date)
and ((@CityId=0 and 1=1) or (@CityId!=0 and s.CityId=@CityId)) and ((@CounterId =0 and 1=1) or (@CounterId !=0 and t.CounterId=@CounterId))
group by (pd.ProductCode),pd.Name,td.UnitPrice


end



GO
/****** Object:  StoredProcedure [dbo].[GetNoveltySaleByDate_Result]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[GetNoveltySaleByDate_Result]
@BrandId int,
@FromDate datetime,
@ToDate datetime
as
begin

select pd.ProductCode,pd.Name,td.UnitPrice,Sum(td.Qty) as TotalQty, Sum(td.TotalAmount) as TotalAmount from NoveltySystem as nv 
inner join ProductInNovelty as pin on pin.NoveltySystemId=nv.Id
left join [TransactionDetail] as td on td.ProductId=pin.ProductId
inner join Product as pd on td.ProductId=pd.Id
left join [Transaction] as t on t.Id=td.TransactionId
left join Customer as c on c.Id=t.CustomerId

where nv.BrandId=@BrandId and pin.IsDeleted=0 and Cast (nv.ValidFrom as Date)=Cast (@FromDate as Date) and Cast(nv.ValidTo as Date)=Cast( @ToDate as Date)
group by (pd.ProductCode),pd.Name,td.UnitPrice


end



GO
/****** Object:  StoredProcedure [dbo].[GetNoveltySaleDate]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[GetNoveltySaleDate]

@BrandId int
as
begin
select distinct Cast (ValidFrom as Date) as ValidFrom,Cast (ValidTo as Date) as ValidTo from NoveltySystem ns,ProductInNovelty pin
where BrandId=@BrandId and ns.Id=pin.NoveltySystemId and pin.IsDeleted=0



end



GO
/****** Object:  StoredProcedure [dbo].[GetProductCode]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[GetProductCode]
@prefix  varchar(20),
@rlength int,
@sLength int
as
begin
	DECLARE @NEWID VARCHAR(10);		
	SELECT @NEWID = (@prefix + replicate('0',@rlength - len(CONVERT(VARCHAR,N.OID + 1))) +
CONVERT(VARCHAR,N.OID + 1)) FROM (
SELECT CASE WHEN MAX(T.TID) IS null then 0 else MAX(T.TID) end as OID FROM (
SELECT SUBSTRING(ProductCode, 5, LEN(Id)) as TID FROM Product Where SUBSTRING(ProductCode,0,@sLength) = @prefix
) AS T 
) AS N
Select @NEWID

End























GO
/****** Object:  StoredProcedure [dbo].[GetProductReport]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[GetProductReport]    
@MainCategoryId int,    
@SubCategoryId int,
@BrandId int,
@SkuCode varchar(100)
as    
begin    
select p.Id ,p.ProductCode,p.Name,b.Name as[Brand Name],p.Qty,0 As PurchasePrice,pC.Name as [Segment Name],
pSubC.Name as [SubSegment Name],p.IsDiscontinue,p.IsConsignment, p.PhotoPath from Product as p    


	 
 left join Brand  as b  on p.BrandId=b.Id    
 left join ProductCategory as pC on p.ProductCategoryId=pC.Id    
 left join ProductSubCategory as pSubC on p.ProductSubCategoryId=pSubC.Id    

 Where  (((@BrandId > 0) and (p.BrandId = @BrandId)) or  ((@BrandId = 0) and (1=1)))
		and (((@MainCategoryId > 0) and (p.ProductCategoryId = @MainCategoryId)) or  ((@MainCategoryId = 0) and (1=1)))
		and (((@SubCategoryId > 0) and (p.ProductSubCategoryId = @SubCategoryId)) or  ((@SubCategoryId = 0) and (1=1)))
		and (((@SkuCode != 0) and (p.ProductCode = @SkuCode)) or  ((@SkuCode = '') and (1=1)))
end























GO
/****** Object:  StoredProcedure [dbo].[GetProfitandLoss]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[GetProfitandLoss]--'2018-06-01','2018-06-17',0,0,0,'MO',1



@fromDate datetime,

@toDate datetime,

@BrandId int,

@ProductId int,

@CounterId int,

 @currentshortcode varchar(2),


 @IsSpecial bit

as
Begin
if @IsSpecial=0
        begin



                Declare  @ProfitAndLossTempTable Table (SaleDate datetime, TotalSaleQty int,TotalSaleAmount bigint,TotalPurchaseAmount bigint,DiscountAmount bigint,TaxAmount bigint,

                ProfitAndLoss bigint)

                        insert Into @ProfitAndLossTempTable



                        select CAST(t.DateTime as date) as SaleDate, SUM(pInt.Qty) as TotalSaleQty,SUM(pInt.Qty * td.UnitPrice) as TotalSaleAmount ,



                        SUM ((pInt.Qty) * purd.UnitPrice) as TotalPurchase,SUM((td.UnitPrice/100)*td.DiscountRate*pInt.Qty) as DiscountAmount ,



                        SUM((td.UnitPrice/100)*td.TaxRate*pInt.Qty) as TaxAmount,
                        SUM (t.TotalAmount-((pInt.Qty) * purd.UnitPrice)) as ProfitAndLoss  from [Transaction] as t



                        inner join TransactionDetail as td on t.Id=td.TransactionId



                        inner join PurchaseDetailInTransaction as pInt on pInt.TransactionDetailId=td.Id



                        inner join PurchaseDetail as purd on purd.Id=pInt.PurchaseDetailId

                                inner join Product as p on p.id=td.ProductId



                        inner join [Brand] as b on b.Id=p.BrandId

                



                        where t.IsDeleted=0 and td.IsDeleted=0 and  CAST(t.DateTime as Date) >=CAST(@fromDate as Date) and CAST(t.DateTime as Date)<=CAST(@toDate as Date)

                        and ((@BrandId = 0 and 1=1) or (@BrandId != 0 and b.id = @BrandId))
                        and ((@ProductId = 0 and 1=1) or (@ProductId != 0 and p.id = @ProductId))
                        and ((@CounterId = 0 and 1=1) or (@CounterId != 0 and t.counterId =@CounterId))
                        and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1)) and pInt.IsSpecialChild=@IsSpecial



                        Group by td.Id, CAST(t.DateTime as date)



                        select CAST(SaleDate as date) as [SaleDate],SUM(TotalSaleQty) as [TotalSaleQty],SUM(TotalSaleAmount -DiscountAmount) as [TotalSaleAmount],
                        SUM(TotalPurchaseAmount) as [TotalPurchaseAmount],SUM(DiscountAmount) as TotalDiscountAmount,SUM(TaxAmount) as TotalTaxAmount,
                        SUM((TotalSaleAmount-DiscountAmount) -TotalPurchaseAmount) as [Total ProfitAndLoss] from @ProfitAndLossTempTable

                        group by CAST(SaleDate as date)



                end

Else
begin
Declare @TempTable Table 
(SaleDate Date,Tid varchar(50),TType varchar(50),Name nvarchar(250),TotalSaleAmount bigint,TotalSaleQty int,TotalDiscountAmount bigint,TotalTaxAmount bigint,TotalPurchaseAmount bigint,TotalProfitAndLoss bigint,
RefundQty int,RefundAmount bigint)
if(select count(trd1.Id) from [Transaction] Tr1,[TransactionDetail] trd1,WrapperItem wpi
 where tr1.Id=trd1.TransactionId and trd1.ProductId=wpi.ParentProductId and tr1.Type in ('Refund','CreditRefund'))>0
begin
insert into @TempTable
select normalt.SaleDate,normalt.Tid,normalt.TType,normalt.Name,normalt.TotalSaleAmount,normalt.TotalSaleQty,
normalt.TotalDiscountAmount,normalt.TotalTaxAmount,normalt.TotalPurchaseAmount,normalt.TotalProfitAndLoss,isnull(reft.RefundQty,0) as RefundQty,ISNULL(reft.RefundAmount,0) as RefundAmount
 from(
(select distinct CAST(T.DateTime as date) SaleDate,T.ID as Tid,T.Type TType,p.Name,sum(distinct td.UnitPrice*td.qty) as TotalSaleAmount,sum(distinct td.Qty) TotalSaleQty,
(sum(distinct td.UnitPrice*td.DiscountRate)/100) as TotalDiscountAmount, SUM(distinct (td.UnitPrice/100)*td.TaxRate*pdit.Qty) as TotalTaxAmount ,
sum((pd.UnitPrice)*(pdit.Qty)) as TotalPurchaseAmount,
0 as TotalProfitAndLoss,case when RefundT.ParentId=t.Id then  sum(distinct RefundT.RefundQty) else 0 end as RefundQty,
case when RefundT.ParentId=t.Id then sum(distinct RefundT.RefundAmount) else 0 end as RefundAmount

 from  [Transaction] T 
inner join [TransactionDetail] td on  T.Id=td.TransactionId
inner join [PurchaseDetailInTransaction] pdit on td.Id=pdit.TransactionDetailId
inner join [PurchaseDetail] pd on pdit.PurchaseDetailId=pd.Id and pdit.ProductId=pd.ProductId
inner join Product p on p.Id=td.productid 
inner join Brand b on b.id=p.BrandID,
(select  distinct tr.ParentId, trd.Qty RefundQty, trd.unitprice RefundAmount,trd.Id rtrid from
[Transaction] tr join 
TransactionDetail trd on tr.Id=trd.TransactionId join 
WrapperItem wpi on wpi.ParentProductId=trd.ProductId 
where trd.IsDeleted=0 and tr.IsDeleted=0 and tr.Type in ('Refund','CreditRefund')) as RefundT



where t.IsDeleted=0 and td.IsDeleted=0 and CAST(T.DateTime as date)>=@fromdate 
and  CAST(T.DateTime as date)<=@todate and pdit.IsSpecialChild=@IsSpecial and RefundT.ParentId=T.Id
 and ((@BrandId = 0 and 1=1) or (@BrandId != 0 and b.id = @BrandId))
                        and ((@ProductId = 0 and 1=1) or (@ProductId != 0 and p.id = @ProductId))
                        and ((@CounterId = 0 and 1=1) or (@CounterId != 0 and t.counterId =@CounterId))
                        and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))

group by CAST(T.DateTime as Date),p.name,t.Id,t.Type,RefundT.ParentId,RefundT.rtrid) as Reft  right join 

(select distinct CAST(T.DateTime as date) SaleDate,T.ID as Tid,T.Type TType,p.Name,sum(distinct td.UnitPrice*td.qty) as TotalSaleAmount,sum(distinct td.Qty) TotalSaleQty,
(sum(distinct td.UnitPrice*td.DiscountRate)/100) as TotalDiscountAmount, SUM(distinct (td.UnitPrice/100)*td.TaxRate*pdit.Qty) as TotalTaxAmount ,
sum((pd.UnitPrice)*(pdit.Qty)) as TotalPurchaseAmount,
0 as TotalProfitAndLoss, 0 as RefundQty,0  as RefundAmount

 from  [Transaction] T 
inner join [TransactionDetail] td on  T.Id=td.TransactionId
inner join [PurchaseDetailInTransaction] pdit on td.Id=pdit.TransactionDetailId
inner join [PurchaseDetail] pd on pdit.PurchaseDetailId=pd.Id and pdit.ProductId=pd.ProductId
inner join Product p on p.Id=td.productid 
inner join Brand b on b.id=p.BrandID
,(select distinct tr.ParentId, trd.Qty RefundQty, trd.unitprice RefundAmount,trd.Id rtrid  from
[Transaction] tr join 
TransactionDetail trd on tr.Id=trd.TransactionId join 
WrapperItem wpi on wpi.ParentProductId=trd.ProductId 
where trd.IsDeleted=0 and tr.IsDeleted=0 and tr.Type in ('Refund','CreditRefund')) as RefundT

where t.IsDeleted=0 and td.IsDeleted=0 and CAST(T.DateTime as date)>=@fromDate 
and  CAST(T.DateTime as date)<=@todate and pdit.IsSpecialChild=@IsSpecial --and RefundT.ParentId!=T.Id
and ((@BrandId = 0 and 1=1) or (@BrandId != 0 and b.id = @BrandId))
                        and ((@ProductId = 0 and 1=1) or (@ProductId != 0 and p.id = @ProductId))
                        and ((@CounterId = 0 and 1=1) or (@CounterId != 0 and t.counterId =@CounterId))
                        and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1)) 

group by CAST(T.DateTime as Date),p.name,t.Id,t.Type,RefundT.ParentId,RefundT.rtrid
) as normalt on Reft.Tid=normalt.Tid) 
select SaleDate,sum(TotalSaleQty-RefundQty) TotalSaleQty,sum(TotalPurchaseAmount) TotalPurchaseAmount,sum(TotalSaleAmount-RefundAmount) TotalSaleAmount,sum(TotalDiscountAmount) TotalDiscountAmount,sum(TotalTaxAmount) TotalTaxAmount,
sum(TotalSaleAmount-TotalDiscountAmount-TotaltaxAmount-totalpurchaseAmount-RefundAmount) [Total ProfitAndLoss]
 from @TempTable
group by SaleDate
end
else
begin
insert into @TempTable
select distinct CAST(T.DateTime as date) SaleDate,T.ID as Tid,T.Type TType,p.Name,sum(distinct td.UnitPrice*td.qty) as TotalSaleAmount,sum(distinct td.Qty) TotalSaleQty,
(sum(distinct td.UnitPrice*td.DiscountRate)/100) as TotalDiscountAmount, SUM(distinct (td.UnitPrice/100)*td.TaxRate*pdit.Qty) as TotalTaxAmount ,
sum((pd.UnitPrice)*(pdit.Qty)) as TotalPurchaseAmount,
0 as TotalProfitAndLoss, 0 as RefundQty,0  as RefundAmount

 from  [Transaction] T 
inner join [TransactionDetail] td on  T.Id=td.TransactionId
inner join [PurchaseDetailInTransaction] pdit on td.Id=pdit.TransactionDetailId
inner join [PurchaseDetail] pd on pdit.PurchaseDetailId=pd.Id and pdit.ProductId=pd.ProductId
inner join Product p on p.Id=td.productid 
inner join Brand b on b.id=p.BrandID

where t.IsDeleted=0 and td.IsDeleted=0 and CAST(T.DateTime as date)>=@fromdate 
and  CAST(T.DateTime as date)<=@todate and pdit.IsSpecialChild=@IsSpecial
and ((@BrandId = 0 and 1=1) or (@BrandId != 0 and b.id = @BrandId))
                        and ((@ProductId = 0 and 1=1) or (@ProductId != 0 and p.id = @ProductId))
                        and ((@CounterId = 0 and 1=1) or (@CounterId != 0 and t.counterId =@CounterId))
                        and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))

group by CAST(T.DateTime as Date),p.name,t.Id,t.Type
select SaleDate,sum(TotalSaleQty-RefundQty) TotalSaleQty,sum(TotalPurchaseAmount) TotalPurchaseAmount,sum(TotalSaleAmount-RefundAmount) TotalSaleAmount,sum(TotalDiscountAmount) TotalDiscountAmount,sum(TotalTaxAmount) TotalTaxAmount,
sum(TotalSaleAmount-TotalDiscountAmount-TotaltaxAmount-totalpurchaseAmount-RefundAmount) [Total ProfitAndLoss]
 from @TempTable
group by SaleDate
end
end
end

GO
/****** Object:  StoredProcedure [dbo].[GetProfitAndLossByBrandId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[GetProfitAndLossByBrandId]

@fromDate datetime,
@toDate datetime,
@BrandId int

as
	begin

		Declare  @ProfitAndLossTempTable Table (SaleDate datetime, TotalSaleQty int,TotalSaleAmount bigint,TotalPurchaseAmount bigint,DiscountAmount bigint,TaxAmount bigint,
		ProfitAndLoss bigint)
			insert Into @ProfitAndLossTempTable

			select CAST(t.DateTime as date) as SaleDate, SUM(pInt.Qty) as TotalSaleQty,SUM(pInt.Qty * td.UnitPrice) as TotalSaleAmount ,

			SUM ((pInt.Qty) * purd.UnitPrice) as TotalPurchase,SUM((td.UnitPrice/100)*td.DiscountRate*pInt.Qty) as DiscountAmount ,

			SUM((td.UnitPrice/100)*tx.TaxPercent*pInt.Qty) as TaxAmount,SUM ((pInt.Qty*td.UnitPrice)-((pInt.Qty) * purd.UnitPrice)) as ProfitAndLoss  from [Transaction] as t

			inner join TransactionDetail as td on t.Id=td.TransactionId

			inner join PurchaseDetailInTransaction as pInt on pInt.TransactionDetailId=td.Id

			inner join PurchaseDetail as purd on purd.Id=pInt.PurchaseDetailId

			inner join Product as p on p.id=td.ProductId

			inner join Brand as b on b.Id=p.BrandId

			inner join Tax as tx on p.TaxId=tx.Id

			where t.IsDeleted=0 and p.BrandId=@BrandId and CAST(t.DateTime as Date) >=CAST(@fromDate as Date) and CAST(t.DateTime as Date)<=CAST(@toDate as Date)

			Group by  CAST(t.DateTime as date)	

			select CAST(SaleDate as date) as [SaleDate],SUM(TotalSaleQty) as [TotalSaleQty],SUM(TotalSaleAmount-DiscountAmount) as [TotalSaleAmount],SUM(TotalPurchaseAmount) as [TotalPurchaseAmount],SUM(DiscountAmount) as TotalDiscountAmount,SUM(TaxAmount) as TotalTaxAmount,SUM((TotalSaleAmount-DiscountAmount) -TotalPurchaseAmount) as [Total ProfitAndLoss] from @ProfitAndLossTempTable
			group by CAST(SaleDate as date)

		end






































GO
/****** Object:  StoredProcedure [dbo].[GetProfitAndLossByCouterId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[GetProfitAndLossByCouterId]

@fromDate datetime,
@toDate datetime,
@counterID bigint

as
	begin

		Declare  @ProfitAndLossTempTable Table (SaleDate datetime, TotalSaleQty int,TotalSaleAmount bigint,TotalPurchaseAmount bigint,DiscountAmount bigint,TaxAmount bigint,
		ProfitAndLoss bigint)
			insert Into @ProfitAndLossTempTable

			select CAST(t.DateTime as date) as SaleDate, SUM(pInt.Qty) as TotalSaleQty,SUM(pInt.Qty * td.UnitPrice) as TotalSaleAmount ,

			SUM ((pInt.Qty) * purd.UnitPrice) as TotalPurchase,SUM((td.UnitPrice/100)*td.DiscountRate*pInt.Qty) as DiscountAmount ,

			SUM((td.UnitPrice/100)*td.TaxRate*pInt.Qty) as TaxAmount,SUM ((pInt.Qty*td.UnitPrice)-((pInt.Qty) * purd.UnitPrice)) as ProfitAndLoss  from [Transaction] as t

			inner join TransactionDetail as td on t.Id=td.TransactionId

			inner join PurchaseDetailInTransaction as pInt on pInt.TransactionDetailId=td.Id

			inner join PurchaseDetail as purd on purd.Id=pInt.PurchaseDetailId	


			where t.IsDeleted=0 and t.CounterId=@counterID and CAST(t.DateTime as Date) >=CAST(@fromDate as Date) and CAST(t.DateTime as Date)<=CAST(@toDate as Date)

			Group by td.Id, CAST(t.DateTime as date)	

			select CAST(SaleDate as date) as [SaleDate],SUM(TotalSaleQty) as [TotalSaleQty],SUM(TotalSaleAmount-DiscountAmount) as [TotalSaleAmount],SUM(TotalPurchaseAmount) as [TotalPurchaseAmount],SUM(DiscountAmount) as TotalDiscountAmount,SUM(TaxAmount) as TotalTaxAmount,SUM((TotalSaleAmount-DiscountAmount) -TotalPurchaseAmount) as [Total ProfitAndLoss] from @ProfitAndLossTempTable
			group by CAST(SaleDate as date)

		end






































GO
/****** Object:  StoredProcedure [dbo].[GetProfitAndLossByProductId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[GetProfitAndLossByProductId]

@fromDate datetime,
@toDate datetime,
@productID bigint

as
	begin

		Declare  @ProfitAndLossTempTable Table (SaleDate datetime, TotalSaleQty int,TotalSaleAmount bigint,TotalPurchaseAmount bigint,DiscountAmount bigint,TaxAmount bigint,
		ProfitAndLoss bigint)
			insert Into @ProfitAndLossTempTable

			select CAST(t.DateTime as date) as SaleDate, SUM(pInt.Qty) as TotalSaleQty,SUM(pInt.Qty * td.UnitPrice) as TotalSaleAmount ,

			SUM ((pInt.Qty) * purd.UnitPrice) as TotalPurchase,SUM((td.UnitPrice/100)*td.DiscountRate*pInt.Qty) as DiscountAmount ,

			SUM((td.UnitPrice/100)*td.TaxRate*pInt.Qty) as TaxAmount,SUM ((pInt.Qty*td.UnitPrice)-((pInt.Qty) * purd.UnitPrice)) as ProfitAndLoss  from [Transaction] as t

			inner join TransactionDetail as td on t.Id=td.TransactionId

			inner join PurchaseDetailInTransaction as pInt on pInt.TransactionDetailId=td.Id

			inner join PurchaseDetail as purd on purd.Id=pInt.PurchaseDetailId

			inner join Product as p on p.Id=td.ProductId 

			where t.IsDeleted=0 and p.Id=@productID and CAST(t.DateTime as Date) >=CAST(@fromDate as Date) and CAST(t.DateTime as Date)<=CAST(@toDate as Date) 

			Group by td.Id, CAST(t.DateTime as date)	

			select CAST(SaleDate as date) as [SaleDate],SUM(TotalSaleQty) as [TotalSaleQty],SUM(TotalSaleAmount-DiscountAmount) as [TotalSaleAmount],SUM(TotalPurchaseAmount) as [TotalPurchaseAmount],SUM(DiscountAmount) as TotalDiscountAmount,SUM(TaxAmount) as TotalTaxAmount,SUM((TotalSaleAmount-DiscountAmount) -TotalPurchaseAmount) as [Total ProfitAndLoss] from @ProfitAndLossTempTable
			group by CAST(SaleDate as date)

		end






































GO
/****** Object:  StoredProcedure [dbo].[GetSaleSpecialPromotionByCustomerId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetSaleSpecialPromotionByCustomerId] 

	@fromDate datetime,

	@toDate datetime,

	@bId int,

	@IsSaleTruePrice bit,

	@currentshortcode varchar(2)

AS
BEGIN
Declare  @SaleSP Table (Id int, Total bigint, Qty int)

	Declare  @RefundSP Table (Id int, Total bigint,Qty int)

	if @IsSaleTruePrice = 0

		Begin

		insert @SaleSP

			select  Br.Id, Sum(SP.Price) as Total, Sum(TD.Qty) as Qty

			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.productId = P.Id

			inner join Brand as B on B.Id = P.BrandId inner join SPDetail as SP on SP.TransactionDetailID = TD.Id

			inner join Product as Pr on Pr.Id = SP.ChildProductID inner join Brand as Br on Br.Id = Pr.BrandId inner join Customer as C on C.Id = T.CustomerId

			where B.Name = 'Special Promotion' and (T.Type = 'Sale' or T.Type = 'Credit')

			 and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date)

			  and T.IsDeleted = 0  and Br.Id = @bId and (TD.IsDeleted IS NULL 

               OR TD.IsDeleted = 0) and T.IsComplete = 1

			   and td.IsFOC=0 and SUBSTRING(T.Id,3,2)=@currentshortcode

			Group By Br.Id

			insert @RefundSP

			select  Br.Id, Sum(SP.Price) as Total, Sum(TD.Qty) as Qty

			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.productId = P.Id

			inner join Brand as B on B.Id = P.BrandId inner join SPDetail as SP on SP.TransactionDetailID = TD.Id

			inner join Product as Pr on Pr.Id = SP.ChildProductID inner join Brand as Br on Br.Id = Pr.BrandId inner join Customer as C on C.Id = T.CustomerId

			where B.Name = 'Special Promotion' and (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) 
			and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsDeleted = 0  and Br.Id = @bId and (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) 
			and T.IsComplete = 1 and td.IsFOC=0 and SUBSTRING(T.Id,3,2)=@currentshortcode

	and (t.ParentId Not Like('%RF%') or t.ParentId is null)

			Group By Br.Id


			select Br.Id as Id,Br.Name as Name, A.Total as TotalSale, A.Qty as SaleQty,B.Total as TotalRefund, B.Qty as RefundQty

			From Brand as Br  Full outer join @SaleSp as A on A.Id = Br.Id

			Full Outer join @RefundSP B on B.Id = Br.Id

			where Br.Id = @bId 

		End

	Else	

		Begin

			insert @SaleSP

			select  Br.Id, Sum((SP.Price - (SP.Price* (SP.DiscountRate/100)))*TD.Qty) as Total, Sum(TD.Qty) as Qty

			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.productId = P.Id

			inner join Brand as B on B.Id = P.BrandId inner join SPDetail as SP on SP.TransactionDetailID = TD.Id

			inner join Product as Pr on Pr.Id = SP.ChildProductID inner join Brand as Br on Br.Id = Pr.BrandId inner join Customer as C on C.Id = T.CustomerId

			where B.Name = 'Special Promotion' and (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date) 
			and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsDeleted = 0  and Br.Id = @bId and (TD.IsDeleted IS NULL 

OR TD.IsDeleted = 0) and T.IsComplete = 1 and (T.PaymentTypeId != 4 and T.PaymentTypeId != 6) and td.IsFOC=0 and SUBSTRING(T.Id,3,2)=@currentshortcode

			Group By Br.Id

			insert @RefundSP

			select  Br.Id, Sum((SP.Price - (SP.Price* (SP.DiscountRate/100)))*TD.Qty) as Total, Sum(TD.Qty) as Qty

			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.productId = P.Id

			inner join Brand as B on B.Id = P.BrandId inner join SPDetail as SP on SP.TransactionDetailID = TD.Id

			inner join Product as Pr on Pr.Id = SP.ChildProductID inner join Brand as Br on Br.Id = Pr.BrandId inner join Customer as C on C.Id = T.CustomerId

			where B.Name = 'Special Promotion' and (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) 
			and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsDeleted = 0  and Br.Id = @bId and (TD.IsDeleted 

IS NULL OR TD.IsDeleted = 0) and T.IsComplete = 1 and (T.PaymentTypeId != 4 and T.PaymentTypeId != 6)
and td.IsFOC=0 and SUBSTRING(T.Id,3,2)=@currentshortcode

			Group By Br.Id

			select Br.Id as Id,Br.Name as Name, A.Total as TotalSale, A.Qty as SaleQty,B.Total as TotalRefund, B.Qty as RefundQty

			From Brand as Br  Full outer join @SaleSp as A on A.Id = Br.Id

			Full Outer join @RefundSP B on B.Id = Br.Id

			where Br.Id = @bId 

		End

END


















































































































































































































































































































































GO
/****** Object:  StoredProcedure [dbo].[GetSaleSpecialPromotionSegmentByCustomerId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetSaleSpecialPromotionSegmentByCustomerId] 

	@fromDate datetime,

	@toDate datetime,

	@bId int,

	@IsSaleTruePrice bit,
	@currentshortcode varchar(2)

AS

BEGIN

	Declare  @SaleSP Table (Id int, Total bigint, Qty int)

	Declare  @RefundSP Table (Id int, Total bigint,Qty int)

	if @IsSaleTruePrice = 1

		

	Begin

			insert @SaleSP

			select  PC.Id, Sum((SP.Price - (SP.Price* (SP.DiscountRate/100)))*TD.Qty) as Total, Sum(TD.Qty) as Qty

			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.productId = P.Id

			inner join Brand as B on B.Id = P.BrandId inner join SPDetail as SP on SP.TransactionDetailID = TD.Id

			inner join Product as Pr on Pr.Id = SP.ChildProductID inner join Brand as Br on Br.Id = Pr.BrandId 
			inner join Customer as C on C.Id = T.CustomerId inner join ProductCategory as PC on Pr.ProductCategoryId = PC.Id

			where B.Name = 'Special Promotion' and (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date) 
			and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsDeleted = 0  
			 and (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) and T.IsComplete = 1 and (T.PaymentTypeId != 4 and T.PaymentTypeId != 6)
			 and td.IsFOC=0  and SUBSTRING(T.Id,3,2)=@currentshortcode
			Group By PC.Id



			insert @RefundSP

			select  PC.Id, Sum((SP.Price - (SP.Price* (SP.DiscountRate/100)))*TD.Qty) as Total, Sum(TD.Qty) as Qty

			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.productId = P.Id

			inner join Brand as B on B.Id = P.BrandId inner join SPDetail as SP on SP.TransactionDetailID = TD.Id

			inner join Product as Pr on Pr.Id = SP.ChildProductID inner join Brand as Br on Br.Id = Pr.BrandId 
			inner join Customer as C on C.Id = T.CustomerId inner join ProductCategory as PC on Pr.ProductCategoryId = PC.Id

			where B.Name = 'Special Promotion' and (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date)
			 and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsDeleted = 0
			  and (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) and T.IsComplete = 1 and (T.PaymentTypeId != 4 and T.PaymentTypeId != 6)
			  and td.IsFOC=0  and SUBSTRING(T.Id,3,2)=@currentshortcode
			Group By PC.Id



			select Br.Id as Id,Br.Name as Name, A.Total as TotalSale, A.Qty as SaleQty,B.Total as TotalRefund, B.Qty as RefundQty

			From ProductCategory as Br  Full outer join @SaleSp as A on A.Id = Br.Id

			Full Outer join @RefundSP B on B.Id = Br.Id

			where Br.Id = @bId



		End

		

	

	Else

	Begin

		

			--insert @SaleSP

			--select  PC.Id, Sum(SP.Price) as Total, Sum(TD.Qty) as Qty

			--from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.productId = P.Id

			--inner join Brand as B on B.Id = P.BrandId inner join SPDetail as SP on SP.TransactionDetailID = TD.Id

			--inner join Product as Pr on Pr.Id = SP.ChildProductID inner join Brand as Br on Br.Id = Pr.BrandId inner join Customer as C on C.Id = T.CustomerId inner join ProductCategory as PC on Pr.ProductCategoryId = PC.Id

			--where B.Name = 'Special Promotion' and (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsDeleted = 0  and (TD.IsDeleted IS NULL OR TD.IsDeleted
-- = 0) and T.IsComplete = 1 and (T.PaymentTypeId != 4 and T.PaymentTypeId != 6)

			--Group By PC.Id



			--insert @RefundSP

			--select  PC.Id, Sum(SP.Price) as Total, Sum(TD.Qty) as Qty

			--from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.productId = P.Id

			--inner join Brand as B on B.Id = P.BrandId inner join SPDetail as SP on SP.TransactionDetailID = TD.Id

			--inner join Product as Pr on Pr.Id = SP.ChildProductID inner join Brand as Br on Br.Id = Pr.BrandId inner join Customer as C on C.Id = T.CustomerId inner join ProductCategory as PC on Pr.ProductCategoryId = PC.Id

			--where B.Name = 'Special Promotion' and (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsDeleted = 0  and (TD.IsDeleted IS NULL OR TD.I
--sDeleted = 0) and T.IsComplete = 1 and (T.PaymentTypeId != 4 and T.PaymentTypeId != 6)

			--Group By PC.Id



			--select Br.Id as Id,Br.Name as Name, A.Total as TotalSale, A.Qty as SaleQty,B.Total as TotalRefund, B.Qty as RefundQty

			--From ProductCategory as Br  Full outer join @SaleSp as A on A.Id = Br.Id

			--Full Outer join @RefundSP B on B.Id = Br.Id

			--where Br.Id = @bId





			insert @SaleSP

			select  PC.Id, Sum(SP.Price) as Total, Sum(TD.Qty) as Qty

			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.productId = P.Id

			inner join Brand as B on B.Id = P.BrandId inner join SPDetail as SP on SP.TransactionDetailID = TD.Id

			inner join Product as Pr on Pr.Id = SP.ChildProductID inner join Brand as Br on Br.Id = Pr.BrandId inner join Customer as C on C.Id = T.CustomerId
			 inner join ProductCategory as PC on Pr.ProductCategoryId = PC.Id

			where B.Name = 'Special Promotion' and (T.Type = 'Sale' or T.Type = 'Credit') 
			and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsDeleted = 0 
			 and (TD.IsDeleted IS NULL OR TD.IsDeleted =
 0) and T.IsComplete = 1 and (T.PaymentTypeId != 4 and T.PaymentTypeId != 6)  and SUBSTRING(T.Id,3,2)=@currentshortcode

			Group By PC.Id



			insert @RefundSP

			select  PC.Id, Sum(SP.Price) as Total, Sum(TD.Qty) as Qty

			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.productId = P.Id

			inner join Brand as B on B.Id = P.BrandId inner join SPDetail as SP on SP.TransactionDetailID = TD.Id

			inner join Product as Pr on Pr.Id = SP.ChildProductID inner join Brand as Br on Br.Id = Pr.BrandId
			 inner join Customer as C on C.Id = T.CustomerId inner join ProductCategory as PC on Pr.ProductCategoryId = PC.Id

			where B.Name = 'Special Promotion' and (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date)
			 and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsDeleted = 0 
			  and (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) and T.IsComplete = 1 and (T.PaymentTypeId != 4 and T.PaymentTypeId != 6)  and SUBSTRING(T.Id,3,2)=@currentshortcode

			Group By PC.Id



			select Br.Id as Id,Br.Name as Name, A.Total as TotalSale, A.Qty as SaleQty,B.Total as TotalRefund, B.Qty as RefundQty

			From ProductCategory as Br  Full outer join @SaleSp as A on A.Id = Br.Id

			Full Outer join @RefundSP B on B.Id = Br.Id

			where Br.Id = @bId



		End

		

END


























































GO
/****** Object:  StoredProcedure [dbo].[GetTicketBy_TDID]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[GetTicketBy_TDID](
@tdid bigint
)
as
select * from Ticket where TransactionDetailId=@tdid

GO
/****** Object:  StoredProcedure [dbo].[GetTicketByQr]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetTicketByQr](
@qr bigint
)
as
declare @localqr varchar(50)
declare @ticketno varchar(20)
declare @tdid int
set @localqr=@qr
select @ticketno=@localqr
select count(*) 'Signal' from Ticket where TicketNo=@ticketno and [Status]=0 and cast(CreatedDate as date)=cast(getdate() as date)

GO
/****** Object:  StoredProcedure [dbo].[GetTotalAmountForCash]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[GetTotalAmountForCash]
@Datetime datetime,
@PaymentTypeID int,
@CounterId int
as 

begin

if(@CounterId>0)

	begin

	select  COUNT(distinct(t.Id))as TotalTransaction ,SUM(td.Qty) as TotalQty ,
	SUM(td.TotalAmount) as TotalAmount



	from [Transaction] as t inner join TransactionDetail as td on t.id=td.TransactionId

	where t.IsDeleted=0 and CAST(t.DateTime as Date)=CAST(@Datetime as Date) and t.PaymentTypeId=@PaymentTypeID and CounterId=@CounterId and ParentId is Null and t.Type='Sale' or t.Type='Credit'




	

	end

else
begin 


					if @PaymentTypeID=1

					begin

					select  COUNT(distinct(t.Id)) as TotalTransaction ,SUM(td.Qty) as TotalQty ,
					SUM(td.TotalAmount)  as TotalAmount



					from [Transaction] as t inner join TransactionDetail as td on t.id=td.TransactionId

					where t.IsDeleted=0 and CAST(t.DateTime as Date)=CAST(@Datetime as Date) and t.PaymentTypeId=@PaymentTypeID and ParentId is Null and  t.Type='Sale'


					end

					if @PaymentTypeID=2

					begin

					select  COUNT(distinct(t.Id)) as TotalTransaction ,SUM(td.Qty) as TotalQty ,
					SUM(td.TotalAmount)  as TotalAmount



					from [Transaction] as t inner join TransactionDetail as td on t.id=td.TransactionId

					where t.IsDeleted=0 and CAST(t.DateTime as Date)=CAST(@Datetime as Date) and t.PaymentTypeId=@PaymentTypeID and ParentId is Null and  t.Type='Credit'


					end



					if @PaymentTypeID=3

					begin

					select  COUNT(distinct(t.Id)) as TotalTransaction ,SUM(td.Qty) as TotalQty ,
					SUM(td.TotalAmount)  as TotalAmount



					from [Transaction] as t inner join TransactionDetail as td on t.id=td.TransactionId

					where t.IsDeleted=0 and CAST(t.DateTime as Date)=CAST(@Datetime as Date) and t.PaymentTypeId=@PaymentTypeID and ParentId is Null and  t.Type='Sale'


					end


					if @PaymentTypeID=4

					begin

					select  COUNT(distinct(t.Id)) as TotalTransaction ,SUM(td.Qty) as TotalQty ,
					SUM(td.TotalAmount)  as TotalAmount



					from [Transaction] as t inner join TransactionDetail as td on t.id=td.TransactionId

					where t.IsDeleted=0 and CAST(t.DateTime as Date)=CAST(@Datetime as Date) and t.PaymentTypeId=@PaymentTypeID and ParentId is Null and  t.Type='Sale'


					end

					if @PaymentTypeID=5

					begin

					select  COUNT(distinct(t.Id)) as TotalTransaction ,SUM(td.Qty) as TotalQty ,
					SUM(td.TotalAmount)  as TotalAmount



					from [Transaction] as t inner join TransactionDetail as td on t.id=td.TransactionId

					where t.IsDeleted=0 and CAST(t.DateTime as Date)=CAST(@Datetime as Date) and t.PaymentTypeId=@PaymentTypeID and ParentId is Null and  t.Type='Sale'


					end

end


end






































GO
/****** Object:  StoredProcedure [dbo].[GetTotalAmountForPrepaid]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[GetTotalAmountForPrepaid]
@Datetime datetime,
@PaymentTypeID int,
@CounterId int
as 

if(@CounterId>0)
begin
select COUNT(distinct(t.Id)) as TotalTransaction ,SUM(td.Qty) as TotalQty ,

SUM(td.TotalAmount)  as TotalAmount

from [Transaction] as t inner join TransactionDetail as td on t.id=td.TransactionId

where t.IsDeleted=0 and CAST(t.DateTime as Date)=CAST(@Datetime as Date) and t.PaymentTypeId=@PaymentTypeID and CounterId=@CounterId and ParentId is Null and t.Type='Prepaid'
end


else

begin

select  COUNT(distinct(t.Id)) as TotalTransaction ,SUM(td.Qty) as TotalQty ,

SUM(td.TotalAmount)  as TotalAmount from [Transaction] as t inner join TransactionDetail as td on t.id=td.TransactionId

where t.IsDeleted=0 and CAST(t.DateTime as Date)=CAST(@Datetime as Date) and t.PaymentTypeId=@PaymentTypeID and  ParentId is Null and t.Type='Prepaid'


end






































GO
/****** Object:  StoredProcedure [dbo].[GetTotalAmountForRefund]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[GetTotalAmountForRefund]
@Datetime datetime,
@CounterId int
as 

if(@CounterId >0)
begin

select CAST(t .DateTime as Date) as SaleDate , COUNT(distinct(t.Id)) as TotalTransaction ,SUM(td.Qty) as TotalQty ,
SUM(td.TotalAmount)  as TotalAmount



from [Transaction] as t inner join TransactionDetail as td on t.id=td.TransactionId

where t.IsDeleted=0 and CAST(t.DateTime as Date)=CAST(@Datetime as Date) and  t.ParentId is not Null and CounterId=@CounterId

group by CAST(t.DateTime as Date)




end
else
begin

select CAST(t .DateTime as Date) as SaleDate , COUNT(distinct(t.Id)) as TotalTransaction ,SUM(td.Qty) as TotalQty ,
SUM(td.TotalAmount)  as TotalAmount



from [Transaction] as t inner join TransactionDetail as td on t.id=td.TransactionId

where t.IsDeleted=0 and CAST(t.DateTime as Date)=CAST(@Datetime as Date) and  t.ParentId is not Null 

group by CAST(t.DateTime as Date)




end






































GO
/****** Object:  StoredProcedure [dbo].[GetTotalTransactionQtyAndQty]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[GetTotalTransactionQtyAndQty]
@Datetime datetime,
@CounterId int
as 

if(@CounterId>0)

begin

select COUNT(distinct(t.Id)) as TotalTransaction ,SUM(td.Qty) as TotalQty ,SUM(td.TotalAmount) as TotalAmount

from [Transaction] as t inner join TransactionDetail as td on t.id=td.TransactionId

where t.IsDeleted=0 and  CAST(t.DateTime as Date)= CAST(@Datetime as Date) and t.Type='Sale' or t.Type='Credit' and CounterId=@CounterId and t.ParentId is null 

end

else
begin

select COUNT(distinct(t.Id)) as TotalTransaction ,SUM(td.Qty) as TotalQty ,SUM(td.TotalAmount) as TotalAmount

from [Transaction] as t inner join TransactionDetail as td on t.id=td.TransactionId

where t.IsDeleted=0 and CAST(t.DateTime as Date)=CAST(@Datetime as Date) and t.Type='Sale' or t.Type='Credit' and t.ParentId is null 

end






































GO
/****** Object:  StoredProcedure [dbo].[GetTransactionByGroup]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetTransactionByGroup]
	
	@fromDate datetime,
	@toDate datetime
	
AS
BEGIN

SELECT					 *
FROM                     [Transaction]
						 WHERE  CAST([Transaction].DateTime as Date) >=CAST(@fromDate as Date) 
						 and CAST([Transaction].DateTime as Date)<=CAST(@toDate as Date) AND ([Transaction].IsDeleted=0) 
						 AND ([Transaction].IsComplete=1) AND ([Transaction].IsActive=1) 
						  AND ([Transaction].PaymentTypeId <> 4)
			
END
















GO
/****** Object:  StoredProcedure [dbo].[InsertDraft]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[InsertDraft]

			@DateTime datetime

           ,@UserId int

           ,@CounterId int

           ,@Type varchar(20)

           ,@IsPaid bit

           ,@IsActive bit

           ,@PaymentTypeId int

           ,@TaxAmount int

           ,@DiscountAmount int

           ,@TotalAmount bigint

           ,@RecieveAmount bigint           

           ,@GiftCardId int

           ,@CustomerId int
		   ,@IsWholeSale bit,
		   @tblorque int=0,
		   @servicefee int =0





AS

BEGIN

	DECLARE @NEWID VARCHAR(10);		

	SELECT @NEWID = ('DF' + replicate('0', 6 - len(CONVERT(VARCHAR,N.OID + 1))) +

CONVERT(VARCHAR,N.OID + 1)) FROM (

SELECT CASE WHEN MAX(T.TID) IS null then 0 else MAX(T.TID) end as OID FROM (

SELECT SUBSTRING(Id, 4, LEN(Id)) as TID FROM [Transaction] Where SUBSTRING(Id,0,3) = 'DF'

) AS T 

) AS N



INSERT INTO [dbo].[Transaction]

           ([Id]

           ,[DateTime]

           ,[UserId]

           ,[CounterId]

           ,[Type]

           ,[IsPaid]

		   ,[IsComplete]

           ,[IsActive]

           ,[PaymentTypeId]

           ,[TaxAmount]

           ,[DiscountAmount]

           ,[TotalAmount]

           ,[RecieveAmount]

         

           ,[GiftCardId]

           ,[CustomerId]
		   
		   ,[IsWholeSale],TableIdOrQue,ServiceFee)

     VALUES

           (@NEWID

           ,@DateTime

           ,@UserId

           ,@CounterId

           ,@Type

           ,@IsPaid

		   ,0

           ,@IsActive

           ,@PaymentTypeId

           ,@TaxAmount

           ,@DiscountAmount

           ,@TotalAmount

           ,@RecieveAmount

           

           ,@GiftCardId

           ,@CustomerId
		   ,@IsWholeSale,@tblorque,@servicefee)



Select @NEWID



END

GO
/****** Object:  StoredProcedure [dbo].[InsertRefundTransaction]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[InsertRefundTransaction]

			@DateTime datetime

           ,@UserId int

           ,@CounterId int

		   ,@Type varchar(20)

           ,@IsPaid bit

           ,@IsActive bit

           ,@PaymentTypeId int

           ,@TaxAmount int

           ,@DiscountAmount int

           ,@TotalAmount bigint

           ,@RecieveAmount bigint

           

		   ,@ParentId varchar(20)

           ,@GiftCardId int

           ,@CustomerId int
		   
			
			,@ShopId int
			,@MemberTypeId int
		



AS

BEGIN

	DECLARE @NEWID VARCHAR(10);		

	SELECT @NEWID = ('RF'+SUBSTRING(@ParentId,3,2) + replicate('0', 6 - len(CONVERT(VARCHAR,N.OID + 1))) +

CONVERT(VARCHAR,N.OID + 1)) FROM (

SELECT CASE WHEN MAX(T.TID) IS null then 0 else MAX(T.TID) end as OID FROM (

SELECT SUBSTRING(Id, 5, LEN(Id)) as TID FROM [Transaction] Where SUBSTRING(Id,0,3) = 'RF' and (IsDeleted=0 or IsActive=0)
) AS T  

) AS N



INSERT INTO [dbo].[Transaction]

           ([Id]

           ,[DateTime]

           ,[UserId]

           ,[CounterId]

           ,[Type]

           ,[IsPaid]

		   ,[IsComplete]

           ,[IsActive]

           ,[PaymentTypeId]

           ,[TaxAmount]

           ,[DiscountAmount]

           ,[TotalAmount]

           ,[RecieveAmount]

           

		   ,[ParentId]

           ,[GiftCardId]

           ,[CustomerId]

		   ,[IsDeleted]
		
			,[UpdatedDate]
			,[IsWholeSale]
			,[IsSettlement]
			,[ShopId]
			,[MemberTypeId]
			
		  )



     VALUES

           (@NEWID

           ,@DateTime

           ,@UserId

           ,@CounterId

           ,@Type

           ,@IsPaid

		   ,1

           ,@IsActive

           ,@PaymentTypeId

           ,@TaxAmount

           ,@DiscountAmount

           ,@TotalAmount

           ,@RecieveAmount

           

		   ,@ParentId

           ,@GiftCardId

           ,@CustomerId

		   ,0
		    ,GETDATE() 
			,0
			,0
			,@ShopId
			,@MemberTypeId

		 )



Select @NEWID



END



GO
/****** Object:  StoredProcedure [dbo].[insertSPDetail]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[insertSPDetail]
	@TransactionDetailID bigint,
	@ParentProductID bigint,
	@ChildProductID bigint,
	@Price bigint,
	@DiscountRate decimal(15,2),
	@ShopCode varchar(20),
	@ChildQty int
	
	
AS
BEGIN
	DECLARE @NEWID VARCHAR(10);		
	SELECT @NEWID = ('SP' + @ShopCode + replicate('0', 6 - len(CONVERT(VARCHAR,N.OID + 1))) +
	CONVERT(VARCHAR,N.OID + 1)) FROM (
	SELECT CASE WHEN MAX(T.TID) IS null then 0 else MAX(T.TID) end as OID FROM (
	SELECT SUBSTRING(SPDetailID, 5, LEN(SPDetailID)) as TID FROM SPDetail Where SUBSTRING(SPDetailID,0,3) = 'SP' And SUBSTRING(SPDetailID,3,2) = @ShopCode
	) AS T 
	) AS N

   INSERT INTO [dbo].[SPDetail]
           ([TransactionDetailID]
		   ,[ParentProductID]
		   ,[ChildProductID]
		   ,[Price]
		   ,[DiscountRate]
		   ,[SPDetailID]
		   ,[ChildQty])
     VALUES
           (@TransactionDetailID
		   ,@ParentProductID
		   ,@ChildProductID
		   ,@Price
		   ,@DiscountRate
		   ,@NEWID
		   ,@ChildQty)

END



GO
/****** Object:  StoredProcedure [dbo].[InsertTicket]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[InsertTicket]
(
@transactionDetailId bigint,
@Status bit=0,
@CreateDate date,
@Category varchar(50)=null,
@ShopCode varchar(2))
as
declare @NewTicket bigint
declare @NEWID varchar(20)
SELECT @NEWID = ('TK'+@ShopCode + replicate('0', 8 - len(CONVERT(VARCHAR,N.OID + 1))) +
CONVERT(VARCHAR,N.OID + 1)) FROM (
SELECT CASE WHEN MAX(T.TID) IS null then 0 else MAX(T.TID) end as OID FROM (
SELECT SUBSTRING(Id, 5, LEN(Id)) as TID FROM Ticket Where SUBSTRING(Id,0,3) = 'TK' And SUBSTRING(Id,3,2) = @ShopCode
) AS T 
) AS N



SELECT @NewTicket = (select substring(replace(convert(date ,GETDATE(),106),'-',''),3,4) + replicate('0', 6 - len(CONVERT(VARCHAR,N.TNo + 1))) +
CONVERT(VARCHAR,N.TNo + 1)) FROM (
SELECT CASE WHEN MAX(T.OT) IS null then 0 else MAX(T.OT) end as TNo FROM (
SELECT SUBSTRING(convert(varchar,TicketNo), 8, LEN(TicketNo)) as OT FROM Ticket where substring(replace(convert(date ,CreatedDate,106),'-',''),3,4)=substring(replace(convert(date ,GETDATE(),106),'-',''),3,4)
) AS T 
) AS N
insert into Ticket (Id,TicketNo,TransactionDetailId,[Status],CreatedDate,Category)
values (@NEWID,@NewTicket,@transactionDetailId,@Status,GETDATE(),@Category)

select @@ROWCOUNT

GO
/****** Object:  StoredProcedure [dbo].[InsertTransaction]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

   
CREATE PROCEDURE [dbo].[InsertTransaction]
			@DateTime datetime
           ,@UserId int
           ,@CounterId int
           ,@Type varchar(20)
           ,@IsPaid bit
           ,@IsActive bit
           ,@PaymentTypeId int
           ,@TaxAmount int
           ,@DiscountAmount int
           ,@TotalAmount bigint
           ,@RecieveAmount bigint
           ,@GiftCardId int
           ,@CustomerId int
           ,@MCDiscountAmt decimal
           ,@BDDiscountAmt decimal
			,@MemberTypeId  int
			,@MCDiscountPercent decimal(5,2)
			,@IsSettlement bit
			,@TranVouNos varchar(1000),
			@IsWholeSale bit
			,@GiftCardAmt decimal(18,2),
			@ShopId int
			  ,@ShopCode varchar(5),
			  @note nvarchar(max),
			  @tableid int=null,
			  @servicefee int=0,
			  @transactionParentId nvarchar(max)
AS
BEGIN
	DECLARE @NEWID VARCHAR(20);		
	Declare @Prefix varchar(10);
	if(@IsWholeSale = 0)
	(
	SELECT @Prefix= 'TS'
	)
	else
	(
	SELECT @Prefix= 'WS'
	)
	
	SELECT @NEWID = (@Prefix + @ShopCode + replicate('0', 8 - len(CONVERT(VARCHAR,N.OID + 1))) +
CONVERT(VARCHAR,N.OID + 1)) FROM (
SELECT CASE WHEN MAX(cast(T.TID as bigint)) IS null then 0 else MAX(cast(T.TID as bigint)) end as OID FROM (
SELECT SUBSTRING(Id, 5, LEN(Id)) as TID FROM [Transaction] Where SUBSTRING(Id,0,3) = @Prefix And SUBSTRING(Id,3,2) = @ShopCode
) AS T 
) AS N


INSERT INTO [dbo].[Transaction]
           ([Id]
           ,[DateTime]
           ,[UserId]
           ,[CounterId]
           ,[Type]
           ,[IsPaid]
		   ,[IsComplete]
           ,[IsActive]
           ,[PaymentTypeId]
           ,[TaxAmount]
           ,[DiscountAmount]
           ,[TotalAmount]
           ,[RecieveAmount]
           ,[GiftCardId]
           ,[CustomerId]
           ,[MCDiscountAmt]
           ,[BDDiscountAmt]
           ,[MemberTypeId]
           ,[MCDiscountPercent]
		   ,[IsSettlement]
		   ,[TranVouNos]
		   ,[IsWholeSale]
		   ,[GiftCardAmount]
		   ,[ShopId]
		   ,[UpdatedDate]
		   ,[Note],[TableIdOrQue],[ServiceFee],
		   ParentId)
     VALUES
           (@NEWID
           ,@DateTime
           ,@UserId
           ,@CounterId
           ,@Type
           ,@IsPaid
		   ,1
           ,@IsActive
           ,@PaymentTypeId
           ,@TaxAmount
           ,@DiscountAmount
           ,@TotalAmount
           ,@RecieveAmount
           ,@GiftCardId
           ,@CustomerId
           ,@MCDiscountAmt
           ,@BDDiscountAmt
           ,@MemberTypeId
           ,@MCDiscountPercent
		   ,@IsSettlement
		   ,@TranVouNos
		   ,@IsWholeSale
		   ,@GiftCardAmt
		   ,@ShopId
		   ,@DateTime
		   ,@note
		   ,@tableid
		   ,@servicefee,
		   @transactionParentId)

Select @NEWID

END





GO
/****** Object:  StoredProcedure [dbo].[InsertTransactionDetail]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertTransactionDetail]  

 @TransactionId varchar(20),  

 @ProductId int,  

 @Qty int,  

 @UnitPrice int,  

 @DiscountRate float,  

 @TaxRate float,  

 @TotalAmount int,  

 @IsDeleted bit  ,

 @ConsignmentPrice bigint,

 @IsConsignmentPaid bit,

 @IsFOC bit,
 @SellingPrice int

AS  

BEGIN  

 INSERT INTo[TransactionDetail]  

(  

 [TransactionDetail].[TransactionId],  

 [TransactionDetail].[ProductId],  

 [TransactionDetail].[Qty],  

 [TransactionDetail].[UnitPrice],  

 [TransactionDetail].[DiscountRate],  

 [TransactionDetail].[TaxRate],  

 [TransactionDetail].[TotalAmount],  

 [TransactionDetail].[IsDeleted]  ,

 [TransactionDetail].[ConsignmentPrice],

 [TransactionDetail].[IsConsignmentPaid],

 [TransactionDetail].[IsFOC],
 
 [TransactionDetail].[SellingPrice]

)   

VALUES  

(  

 @TransactionId,  

 @ProductId,  

 @Qty,  

 @UnitPrice,  

 @DiscountRate,  

 @TaxRate,  

 @TotalAmount,  

 @IsDeleted  ,

 @ConsignmentPrice,

 @IsConsignmentPaid,

   @IsFOC,

  @SellingPrice

);  

SELECT SCOPE_IDENTITY();  

END


















GO
/****** Object:  StoredProcedure [dbo].[NetIncomeReportByYearMonth]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[NetIncomeReportByYearMonth]
@Year int, 
@Month int
as
begin
select 
Product.Id,
Product.Price  as Price,
Product.ProductCode as ProductCode,
StockTransaction.Purchase as Purchase,
StockTransaction.Refund as Refund,
StockTransaction.Sale as Sale,
StockTransaction.AdjustmentStockIn as AdjustmentStockIn,
StockTransaction.AdjustmentStockOut,
StockTransaction.Consignment,
StockTransaction.ConversionStockIn,
StockTransaction.ConversionStockOut,
StockTransaction.StockIn,
StockTransaction.StockOut,
StockTransaction.Opening,
(StockTransaction.Opening+StockTransaction.Purchase+StockTransaction.Refund +StockTransaction.AdjustmentStockIn+StockTransaction.Consignment+StockTransaction.ConversionStockIn+StockTransaction.StockIn)-(StockTransaction.Sale+StockTransaction.AdjustmentStockOut+StockTransaction.ConversionStockOut+StockTransaction.StockOut) as Closing
 from Product 
left join StockTransaction on StockTransaction.ProductId=Product.Id
where StockTransaction.Month=@Month and StockTransaction.Year=@Year
union  all
select 
Product.Id,
Product.Price  as Price,
Product.ProductCode as ProductCode,
isnull(0,0) as Purchase,
isnull(0,0) as Refund,
isnull(0,0) as Sale,
isnull(0,0) as AdjustmentStockIn,
isnull(0,0)as AdjustmentStockOut,
isnull(0,0)as Consignment,
isnull(0,0)as ConversionStockIn,
isnull(0,0)as ConversionStockOut,
isnull(0,0) as StockIn,
isnull(0,0)as StockOut,
isnull(product.Qty,0) as Opening,
isnull(product.Qty,0) as Closing
 from Product 
where Product.Id not in (select ProductId from StockTransaction where StockTransaction.Month=@Month and StockTransaction.Year=@Year)
end

GO
/****** Object:  StoredProcedure [dbo].[Paid]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Paid]
	@paid bit,
	@Id varchar(50)
AS
	UPDATE [Transaction] Set IsPaid = @paid where Id = @Id
RETURN 0






































GO
/****** Object:  StoredProcedure [dbo].[ProductCdoe]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[ProductCdoe]
@prefix  varchar(20)
as
begin
	DECLARE @NEWID VARCHAR(10);		
	SELECT @NEWID = (@prefix + replicate('0', 6 - len(CONVERT(VARCHAR,N.OID + 1))) +
CONVERT(VARCHAR,N.OID + 1)) FROM (
SELECT CASE WHEN MAX(T.TID) IS null then 0 else MAX(T.TID) end as OID FROM (
SELECT SUBSTRING(ProductCode, 4, LEN(Id)) as TID FROM Product Where SUBSTRING(ProductCode,0,3) = @prefix
) AS T 
) AS N
Select @NEWID

End






































GO
/****** Object:  StoredProcedure [dbo].[ProductReportByBId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[ProductReportByBId]    
@BrandId int    
AS    
begin     
    
select  pd.Id,pd.ProductCode,pd.Name,PC.Name as [Segment Name],PdSC.Name as [SubSegment Name],bd.Name as [Brand Name],pd.Qty,
0 As PurchasePrice,pd.IsDiscontinue,pd.IsConsignment, pd.PhotoPath from Product as pd     
left join  ProductCategory as PC on pd.ProductCategoryId=PC.Id     
left join  ProductSubCategory as PdSC on pd.ProductSubCategoryId=PdSC.Id    
left join Brand as bd on pd.BrandId=bd.Id Where pd.BrandId=@BrandId    
    
end



































GO
/****** Object:  StoredProcedure [dbo].[ProductReportByCId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[ProductReportByCId]    
@MainCategoryId int     
AS    
begin     
select pd.Id,pd.ProductCode,pd.Name,PC.Name as [Segment Name],PdSC.Name as [SubSegment Name],bd.Name as [Brand Name],pd.Qty,0 As PurchasePrice,
pd.IsDiscontinue,pd.IsConsignment, pd.PhotoPath from Product as pd     
left join  ProductCategory as PC on pd.ProductCategoryId=PC.Id     
left join  ProductSubCategory as PdSC on pd.ProductSubCategoryId=PdSC.Id    
left join Brand as bd on pd.BrandId=bd.Id Where pd.ProductCategoryId=@MainCategoryId    
end
































GO
/****** Object:  StoredProcedure [dbo].[ProductReportByCIdAndBId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[ProductReportByCIdAndBId]    
@BrandId int,    
@MainCategoryId int    
AS    
begin    
    
select pd.Id,pd.ProductCode,pd.Name,PC.Name as [Segment Name],PdSC.Name as [SubSegment Name],bd.Name as [Brand Name],pd.Qty,
0 As PurchasePrice,pd.IsDiscontinue,pd.IsConsignment, pd.PhotoPath from Product as pd     
left join  ProductCategory as PC on pd.ProductCategoryId=PC.Id     
left join  ProductSubCategory as PdSC on pd.ProductSubCategoryId=PdSC.Id    
left join Brand as bd on pd.BrandId=bd.Id Where pd.ProductCategoryId=@MainCategoryId and pd.BrandId=@BrandId    
    
end

































GO
/****** Object:  StoredProcedure [dbo].[ProductReportBySCIdAndCId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[ProductReportBySCIdAndCId]    
@MainCategoryId int,    
@SubCategoryId int    
AS    
begin     
BEGIN    
    
if(@SubCategoryId=1)    
    
select  pd.Id,pd.ProductCode,pd.Name,PC.Name as [Segment Name],PdSC.Name as [SubSegment Name],bd.Name as [Brand Name],pd.Qty ,
0 As PurchasePrice,pd.IsDiscontinue,pd.IsConsignment, pd.PhotoPath  from Product as pd     
inner join  ProductCategory as PC on pd.ProductCategoryId=PC.Id     
inner join  ProductSubCategory as PdSC on pd.ProductSubCategoryId=PdSC.Id    
inner join Brand as bd on pd.BrandId=bd.Id Where pd.ProductCategoryId=@MainCategoryId and pd.ProductSubCategoryId is Null    
    
else    
select   pd.Id,pd.ProductCode,pd.Name,PC.Name as [Segment Name],PdSC.Name as [SubSegment Name],bd.Name as [Brand Name],pd.Qty,
0 As PurchasePrice,pd.IsDiscontinue,pd.IsConsignment, pd.PhotoPath  from Product as pd     
inner join  ProductCategory as PC on pd.ProductCategoryId=PC.Id     
inner join  ProductSubCategory as PdSC on pd.ProductSubCategoryId=PdSC.Id    
inner join Brand as bd on pd.BrandId=bd.Id Where pd.ProductCategoryId=@MainCategoryId and pd.ProductSubCategoryId=@SubCategoryId    
End    
end

































GO
/****** Object:  StoredProcedure [dbo].[ProductReportBySCIdAndCIdAndBId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[ProductReportBySCIdAndCIdAndBId]    
@MainCategoryId int,    
@SubCategoryId int,    
@BrandId int    
AS    
begin     
BEGIN    
    
if(@SubCategoryId=0)    
    
select pd.Id,pd.ProductCode,pd.Name,PC.Name as [Segment Name],PdSC.Name as [SubSegment Name],bd.Name as [Brand Name],pd.Qty ,
0 As PurchasePrice,pd.IsDiscontinue,pd.IsConsignment, pd.PhotoPath  from Product as pd     
left join  ProductCategory as PC on pd.ProductCategoryId=PC.Id     
left join  ProductSubCategory as PdSC on pd.ProductSubCategoryId=PdSC.Id    
left join Brand as bd on pd.BrandId=bd.Id Where pd.ProductCategoryId=@MainCategoryId and pd.ProductSubCategoryId is Null and pd.BrandId=@BrandId    
    
else    
select pd.Id,pd.ProductCode,pd.Name,PC.Name as [Segment Name],PdSC.Name as [SubSegment Name],bd.Name as [Brand Name],pd.Qty,
0 As PurchasePrice,pd.IsDiscontinue,pd.IsConsignment, pd.PhotoPath  from Product as pd     
left join  ProductCategory as PC on pd.ProductCategoryId=PC.Id     
left join  ProductSubCategory as PdSC on pd.ProductSubCategoryId=PdSC.Id    
left join Brand as bd on pd.BrandId=bd.Id Where pd.ProductCategoryId=@MainCategoryId and pd.ProductSubCategoryId=@SubCategoryId and pd.BrandId=@BrandId    
END    
End

































GO
/****** Object:  StoredProcedure [dbo].[PurchaseDiscountReport]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[PurchaseDiscountReport]
@fromDate datetime,
@toDate datetime,
@supplierId int
as
begin

if @supplierId=0
	begin

		select Date as [Purchase Date] , VoucherNo,sp.Name as SupplierName,TotalAmount,DiscountAmount   from MainPurchase as mp 

		inner join Supplier as sp on sp.Id =mp.SupplierId  

		where mp.DiscountAmount >0 and mp.IsDeleted=0 and CAST(@fromDate as Date) <=CAST(mp.Date as Date) and CAST(@toDate as date) >=CAST(mp.Date as Date) and mp.IsDeleted=0
	end


else
	begin	

		select Date as [Purchase Date] , VoucherNo,sp.Name as SupplierName,TotalAmount,DiscountAmount   from MainPurchase as mp 

		inner join Supplier as sp on sp.Id =mp.SupplierId  

		where mp.DiscountAmount >0 and mp.IsDeleted=0 and CAST(@fromDate as Date) <=CAST(mp.Date as Date)
		 and CAST(@toDate as date) >=CAST(mp.Date as Date) and mp.SupplierId=@supplierId and mp.IsDeleted=0
		   and mp.IsCompletedInvoice=1
	end
end















GO
/****** Object:  StoredProcedure [dbo].[PurchaseReport]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[PurchaseReport]  
  
@fromDate datetime,  
@toDate datetime,  
@SupplierId int,  
@BrandId int,  
@ProductId int,  
@SearchType varchar(20)  
  
as  
  
if(@SearchType='SupplierName')  
  
 begin   
  select mp.Date,p.Name as ProductName,sp.Name as SupplierName,pd.UnitPrice,pd.Qty,mp.TotalAmount,mp.VoucherNo from MainPurchase as mp   
  inner join PurchaseDetail as pd  on mp.Id=pd.MainPurchaseId  
  inner join Product as p on p.Id=pd.ProductId  
  inner join Brand as b on b.Id=p.BrandId  
  inner join Supplier as  sp on sp.Id=mp.SupplierId   
  
  where CAST(mp.Date as date) >= CAST(@fromDate as date) and CAST(mp.Date as date) <= CAST(@toDate as date) 
  and mp.SupplierId=@SupplierId and mp.IsDeleted=0  and pd.IsDeleted=0 and mp.IsPurchase=1
  and mp.IsCompletedInvoice=1
 end  
  
else if(@SearchType='BrandName')  
  
 begin   
  select mp.Date,p.Name as ProductName,sp.Name as SupplierName,pd.UnitPrice,pd.Qty,mp.TotalAmount,mp.VoucherNo from MainPurchase as mp   
  inner join PurchaseDetail as pd  on mp.Id=pd.MainPurchaseId  
  inner join Product as p on p.Id=pd.ProductId  
  inner join Brand as b on b.Id=p.BrandId  
  inner join Supplier as  sp on sp.Id=mp.SupplierId  
  
  where CAST(mp.Date as date) >= CAST(@fromDate as date) and CAST(mp.Date as date) <= CAST(@toDate as date) and b.Id=@BrandId 
  and mp.IsDeleted=0  and pd.IsDeleted=0 and mp.IsPurchase=1
  and mp.IsCompletedInvoice=1
 end  
  
  
  
else if(@SearchType='ProductName')  
  
 begin   
  select mp.Date,p.Name as ProductName,sp.Name as SupplierName,pd.UnitPrice,pd.Qty,mp.TotalAmount,mp.VoucherNo from MainPurchase as mp   
  inner join PurchaseDetail as pd  on mp.Id=pd.MainPurchaseId  
  inner join Product as p on p.Id=pd.ProductId  
  inner join Brand as b on b.Id=p.BrandId  
  inner join Supplier as  sp on sp.Id=mp.SupplierId  
  
  where CAST(mp.Date as date) >= CAST(@fromDate as date) and CAST(mp.Date as date) <= CAST(@toDate as date) and pd.ProductId =@ProductId 
  and mp.IsDeleted=0   and pd.IsDeleted=0 and mp.IsPurchase=1
  and mp.IsCompletedInvoice=1
 end  
  
 else  
  
 begin   
  select mp.Date,p.Name as ProductName,sp.Name as SupplierName,pd.UnitPrice,pd.Qty,mp.TotalAmount,mp.VoucherNo from MainPurchase as mp   
  inner join PurchaseDetail as pd  on mp.Id=pd.MainPurchaseId  
  inner join Product as p on p.Id=pd.ProductId  
  inner join Brand as b on b.Id=p.BrandId  
  inner join Supplier as  sp on sp.Id=mp.SupplierId  
  
  where CAST(mp.Date as date) >= CAST(@fromDate as date) and CAST(mp.Date as date) <= CAST(@toDate as date) and mp.IsDeleted=0   
  and pd.IsDeleted=0 and mp.IsPurchase=1
  and mp.IsCompletedInvoice=1
 end



















GO
/****** Object:  StoredProcedure [dbo].[RefundItemList]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RefundItemList]
	 @fromDate datetime,
	@toDate datetime
AS
	Select TD.ProductId as ItemId, P.Name as ItemName, SUM(TD.Qty) as ItemQty, SUM(TD.TotalAmount) as ItemTotalAmount
	from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id
	where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date)
	Group By TD.ProductId, P.Name;
RETURN 0






































GO
/****** Object:  StoredProcedure [dbo].[SaleBreakDownByRangeWithSaleTrueValue]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SaleBreakDownByRangeWithSaleTrueValue]

	@fromDate datetime,

	@toDate datetime,

	@isSp bit,

	@currentshortcode varchar(2)

AS

	Declare  @SaleByFromToDate Table (Id int, Total bigint, Qty int)

	Declare  @RefundByFromToDate Table (Id int, Total bigint,Qty int)

	if @isSp =0

	Begin

		insert into @SaleByFromToDate

		select P.BrandId as BId, Sum(TD.TotalAmount) as DSTP, Sum(TD.Qty) as Qty

		from [Transaction] as T inner join TransactionDetail as TD on TD.TransactionId = T.Id

		inner join Product as P on P.Id = TD.ProductId	

		right join Brand as B on B.Id = P.BrandId

		where (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date)

		 and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsDeleted = 0 and B.Name !=  'Special Promotion'

		  and (TD.IsDeleted IS NULL OR TD.IsDeleted =0) and T.IsComplete = 1 and (T.PaymentTypeId != 4 and T.PaymentTypeId != 6)
		  and td.IsFOC=0 and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))

		Group By P.BrandId

		insert into @RefundByFromToDate

		select P.BrandId as BId, Sum(TD.TotalAmount) as DSTP, Sum(TD.Qty) as Qty

		from [Transaction] as T inner join TransactionDetail as TD on TD.TransactionId = T.Id

		inner join Product as P on P.Id = TD.ProductId	

		right join Brand as B on B.Id = P.BrandId

		where (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) 

		and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsDeleted = 0 and B.Name != 'Special Promotion' 

		and (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) and (T.PaymentTypeId != 4 and T.PaymentTypeId != 6)

		and td.IsFOC=0 and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))

		Group By P.BrandId

		select Br.Id as Id,Br.Name as Name, A.Total as TotalSale, A.Qty as SaleQty,B.Total as TotalRefund, B.Qty as RefundQty

		From Brand as Br Full outer join @SaleByFromToDate as A on Br.Id = A.Id	

		Full outer join @RefundByFromToDate as B on Br.Id = B.Id

		where  Br.Name != 'Special Promotion'

	end	
	else		

	Begin

		insert into @SaleByFromToDate

		select P.BrandId as BId, Sum(TD.TotalAmount) as DSTP, Sum(TD.Qty) as Qty

		from [Transaction] as T inner join TransactionDetail as TD on TD.TransactionId = T.Id

		inner join Product as P on P.Id = TD.ProductId	

		right join Brand as B on B.Id = P.BrandId

		where (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date) 

		and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsDeleted = 0 and B.Name =  'Special Promotion' 

		and (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) and T.IsComplete = 1 and (T.PaymentTypeId != 4 and T.PaymentTypeId != 6)
		and td.IsFOC=0 and SUBSTRING(T.Id,3,2)=@currentshortcode

		Group By P.BrandId

		insert into @RefundByFromToDate

		select P.BrandId as BId, Sum(TD.TotalAmount) as DSTP, Sum(TD.Qty) as Qty

		from [Transaction] as T inner join TransactionDetail as TD on TD.TransactionId = T.Id

		inner join Product as P on P.Id = TD.ProductId	

		right join Brand as B on B.Id = P.BrandId

		where (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) 

		and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsDeleted = 0 and B.Name = 'Special Promotion'

		 and (TD.IsDeleted IS NULL OR TD.IsDeleted = 0)  and (T.PaymentTypeId != 4 and T.PaymentTypeId != 6)

		 and td.IsFOC=0 and SUBSTRING(T.Id,3,2)=@currentshortcode

		Group By P.BrandId

		select Br.Id as Id,Br.Name as Name, Sum(A.Total) as TotalSale, Sum(A.Qty) as SaleQty,Sum(B.Total) as TotalRefund, Sum(B.Qty) as RefundQty

		From Brand as Br left join @SaleByFromToDate as A on Br.Id = A.Id	

		left join @RefundByFromToDate as B on Br.Id = B.Id

		where  Br.Name = 'Special Promotion'

		Group By Br.Id, Br.Name

		end

GO
/****** Object:  StoredProcedure [dbo].[SaleBreakDownByRangeWithUnitValue]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SaleBreakDownByRangeWithUnitValue]

	@fromDate datetime,

	@toDate datetime,

	@isSp bit,

	@currentshortcode varchar(2)

AS

	Declare  @SaleByFromToDate Table (Id int, Total bigint, Qty int)

	Declare  @RefundByFromToDate Table (Id int, Total bigint,Qty int)

	if @isSp =0

	Begin

		insert into @SaleByFromToDate

		select P.BrandId as BId, Sum(TD.UnitPrice *TD.Qty) as DSTP, Sum(TD.Qty) as Qty

		from [Transaction] as T inner join TransactionDetail as TD on TD.TransactionId = T.Id

		inner join Product as P on P.Id = TD.ProductId	

		right join Brand as B on B.Id = P.BrandId

		where (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date)

		 and CAST(T.DateTime as date) <= CAST(@toDate as date)  and  B.Name !=  'Special Promotion'

		  and (T.IsDeleted IS NULL OR T.IsDeleted = 0) and  (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) and T.IsComplete = 1

		  and td.IsFOC=0 and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))

		Group By P.BrandId

		insert into @RefundByFromToDate
	select P.BrandId as BId, Sum(TD.UnitPrice *TD.Qty) as DSTP, Sum(TD.Qty) as Qty

		from [Transaction] as T inner join TransactionDetail as TD on TD.TransactionId = T.Id

		inner join Product as P on P.Id = TD.ProductId	

		right join Brand as B on B.Id = P.BrandId

		where (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date)

		 and CAST(T.DateTime as date) <= CAST(@toDate as date) and B.Name !=  'Special Promotion' and (T.IsDeleted IS NULL OR T.IsDeleted = 0) 

		 and  (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) and T.IsComplete = 1
		 and td.IsFOC=0 and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))

		Group By P.BrandId

		select Br.Id as Id,Br.Name as Name, A.Total as TotalSale, A.Qty as SaleQty,B.Total as TotalRefund, B.Qty as RefundQty

		From Brand as Br Full outer join @SaleByFromToDate as A on Br.Id = A.Id	

		Full outer join @RefundByFromToDate as B on Br.Id = B.Id

		where Br.Name != 'Special Promotion'

		end

	Else

	Begin

		insert into @SaleByFromToDate

		select P.BrandId as BId, Sum(P.Price * TD.Qty) as DSTP, Sum(TD.Qty) as Qty

		from [Transaction] as T inner join TransactionDetail as TD on TD.TransactionId = T.Id

		inner join Product as P on P.Id = TD.ProductId	

		right join Brand as B on B.Id = P.BrandId

		where (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date)

 and CAST(T.DateTime as date) <= CAST(@toDate as date) and (T.IsDeleted IS NULL OR T.IsDeleted = 0) and B.Name =  'Special Promotion' 

		 and (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) and T.IsComplete = 1
		 and td.IsFOC=0 and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))

		Group By P.BrandId

		insert into @RefundByFromToDate

		select P.BrandId as BId, Sum(P.Price *TD.Qty) as DSTP, Sum(TD.Qty) as Qty

		from [Transaction] as T inner join TransactionDetail as TD on TD.TransactionId = T.Id

		inner join Product as P on P.Id = TD.ProductId	

		right join Brand as B on B.Id = P.BrandId

		where (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date)

		 and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsDeleted = 0 and B.Name =  'Special Promotion' 

		 and (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) and T.IsComplete = 1
		 and td.IsFOC=0 and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))

		Group By P.BrandId

		select Br.Id as Id,Br.Name as Name, A.Total as TotalSale, A.Qty as SaleQty,B.Total as TotalRefund, B.Qty as RefundQty

		From Brand as Br Full outer join @SaleByFromToDate as A on Br.Id = A.Id	

		Full outer join @RefundByFromToDate as B on Br.Id = B.Id

		where Br.Name = 'Special Promotion'

		end

GO
/****** Object:  StoredProcedure [dbo].[SaleBreakDownBySegmentWithSaleTrueValue]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SaleBreakDownBySegmentWithSaleTrueValue]

	@fromDate datetime,

	@toDate datetime,

	@isSp bit,

	@currentshortcode varchar(2)

AS

	Declare  @SaleByFromToDate Table (Id int, Total bigint, Qty int)

	Declare  @RefundByFromToDate Table (Id int, Total bigint,Qty int)

	if @isSP =0

	Begin

		



			insert into @SaleByFromToDate

			select P.ProductCategoryId as CId, Sum(TD.TotalAmount) as DSTP, Sum(TD.Qty) as Qty

			from [Transaction] as T inner join TransactionDetail as TD on TD.TransactionId = T.Id

			inner join Product as P on P.Id = TD.ProductId	inner join Brand as B on B.Id = P.BrandId

			right join ProductCategory as C on C.Id = P.ProductCategoryId

			where (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date)
			 and CAST(T.DateTime as date) <= CAST(@toDate as date) and B.Name !=  'Special Promotion' and  (T.IsDeleted IS NULL OR T.IsDeleted = 0) 
			 and  (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) and T.IsComplete = 1
			 and td.IsFOC=0  and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))

			Group By P.ProductCategoryId

	

			insert into @RefundByFromToDate

			select P.ProductCategoryId as CId, Sum(TD.TotalAmount) as DSTP, Sum(TD.Qty) as Qty

			from [Transaction] as T inner join TransactionDetail as TD on TD.TransactionId = T.Id

			inner join Product as P on P.Id = TD.ProductId	inner join Brand as B on B.Id = P.BrandId

			right join ProductCategory as C on C.Id = P.ProductCategoryId

			where (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) 
			and CAST(T.DateTime as date) <= CAST(@toDate as date) and B.Name !=  'Special Promotion' 
			and (T.IsDeleted IS NULL OR T.IsDeleted = 0) and  (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) and T.IsComplete = 1
			and td.IsFOC=0  and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))
			Group BY P.ProductCategoryId



			select C.Id as Id,C.Name as Name, A.Total as TotalSale, A.Qty as SaleQty,B.Total as TotalRefund, B.Qty as RefundQty

			From ProductCategory as C Full outer join @SaleByFromToDate as A on C.Id = A.Id	

			Full outer join @RefundByFromToDate as B on C.Id = B.Id 

			where C.Name != 'Special Promotion'

		

			

	End

	Else

	Begin

		



			insert into @SaleByFromToDate

			select P.ProductCategoryId as CId, Sum(TD.TotalAmount) as DSTP, Sum(TD.Qty) as Qty

			from [Transaction] as T inner join TransactionDetail as TD on TD.TransactionId = T.Id

			inner join Product as P on P.Id = TD.ProductId	inner join Brand as B on B.Id = P.BrandId

			right join ProductCategory as C on C.Id = P.ProductCategoryId

			where (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date) 
			and CAST(T.DateTime as date) <= CAST(@toDate as date) and (T.IsDeleted IS NULL OR T.IsDeleted = 0) and B.Name = 'Special Promotion' 
			and (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) and T.IsComplete = 1
			and td.IsFOC=0  and SUBSTRING(T.Id,3,2)=@currentshortcode
			Group By P.ProductCategoryId



	

			insert into @RefundByFromToDate

			select P.ProductCategoryId as CId, Sum(TD.TotalAmount) as DSTP, Sum(TD.Qty) as Qty

			from [Transaction] as T inner join TransactionDetail as TD on TD.TransactionId = T.Id

			inner join Product as P on P.Id = TD.ProductId	inner join Brand as B on B.Id = P.BrandId

			right join ProductCategory as C on C.Id = P.ProductCategoryId

			where (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) 
			and CAST(T.DateTime as date) <= CAST(@toDate as date) and (T.IsDeleted IS NULL OR T.IsDeleted = 0) and B.Name = 'Special Promotion' 
			and (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) and T.IsComplete = 1
			and td.IsFOC=0  and SUBSTRING(T.Id,3,2)=@currentshortcode
			Group BY P.ProductCategoryId



			select C.Id as Id,C.Name as Name, A.Total as TotalSale, A.Qty as SaleQty,B.Total as TotalRefund, B.Qty as RefundQty

			From ProductCategory as C Full outer join @SaleByFromToDate as A on C.Id = A.Id	

			Full outer join @RefundByFromToDate as B on C.Id = B.Id  

			where C.Name = 'Special Promotion'



			end

GO
/****** Object:  StoredProcedure [dbo].[SaleBreakDownBySegmentWithUnitValue]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SaleBreakDownBySegmentWithUnitValue]

	@fromDate datetime,

	@toDate datetime,	

	@isSp bit,
	@currentshortcode varchar(2)

AS

	Declare  @SaleByFromToDate Table (Id int, Total bigint, Qty int)

	Declare  @RefundByFromToDate Table (Id int, Total bigint,Qty int)



	if @isSp =0

	Begin 


		insert into @SaleByFromToDate

		select P.ProductCategoryId as CId, Sum(TD.UnitPrice *TD.Qty) as DSTP, Sum(TD.Qty) as Qty

		from [Transaction] as T inner join TransactionDetail as TD on TD.TransactionId = T.Id

		inner join Product as P on P.Id = TD.ProductId inner join Brand as B on B.Id = P.BrandId	

		right join ProductCategory as C on C.Id = P.ProductCategoryId

		where (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date) 
		and CAST(T.DateTime as date) <= CAST(@toDate as date) and B.Name !=  'Special Promotion' and (T.IsDeleted IS NULL OR T.IsDeleted = 0) 
		and  (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) and T.IsComplete = 1
		and td.IsFOC=0  and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))
		Group By P.ProductCategoryId



	

		insert into @RefundByFromToDate

		select P.ProductCategoryId as CId, Sum(TD.UnitPrice *TD.Qty) as DSTP, Sum(TD.Qty) as Qty

		from [Transaction] as T inner join TransactionDetail as TD on TD.TransactionId = T.Id

		inner join Product as P on P.Id = TD.ProductId	inner join Brand as B on B.Id = P.BrandId

		right join ProductCategory as C on C.Id = P.ProductCategoryId

		where (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) 
		and CAST(T.DateTime as date) <= CAST(@toDate as date) and B.Name !=  'Special Promotion' and (T.IsDeleted IS NULL OR T.IsDeleted = 0) 
		and (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) and T.IsComplete = 1
		and td.IsFOC=0  and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))
		Group BY P.ProductCategoryId



		select Br.Id as Id,Br.Name as Name, A.Total as TotalSale, A.Qty as SaleQty,B.Total as TotalRefund, B.Qty as RefundQty

		From ProductCategory as Br Full outer join @SaleByFromToDate as A on Br.Id = A.Id	

		Full outer join @RefundByFromToDate as B on Br.Id = B.Id

		--where Br.Name != 'Special Promotion'		

		

		

	End



	else



	Begin		



		insert into @SaleByFromToDate

		select P.ProductCategoryId as CId, Sum(TD.UnitPrice *TD.Qty) as DSTP, Sum(TD.Qty) as Qty

		from [Transaction] as T inner join TransactionDetail as TD on TD.TransactionId = T.Id

		inner join Product as P on P.Id = TD.ProductId inner join Brand as B on B.Id = P.BrandId	

		right join ProductCategory as C on C.Id = P.ProductCategoryId

		where (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date) 
		and CAST(T.DateTime as date) <= CAST(@toDate as date) and (T.IsDeleted IS NULL OR T.IsDeleted = 0) and B.Name = 'Special Promotion'
		 and (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) and T.IsComplete = 1
		 and td.IsFOC=0  and SUBSTRING(T.Id,3,2)=@currentshortcode
		Group By P.ProductCategoryId



	

		insert into @RefundByFromToDate

		select P.ProductCategoryId as CId, Sum(TD.UnitPrice *TD.Qty) as DSTP, Sum(TD.Qty) as Qty

		from [Transaction] as T inner join TransactionDetail as TD on TD.TransactionId = T.Id

		inner join Product as P on P.Id = TD.ProductId inner join Brand as B on B.Id = P.BrandId	 

		right join ProductCategory as C on C.Id = P.ProductCategoryId

		where (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date)
		 and CAST(T.DateTime as date) <= CAST(@toDate as date) and (T.IsDeleted IS NULL OR T.IsDeleted = 0) and B.Name = 'Special Promotion' 
		 and (TD.IsDeleted IS NULL OR TD.IsDeleted = 0) and T.IsComplete = 1
		 and td.IsFOC=0  and SUBSTRING(T.Id,3,2)=@currentshortcode
		Group BY P.ProductCategoryId



		select Br.Id as Id,Br.Name as Name, A.Total as TotalSale, A.Qty as SaleQty,B.Total as TotalRefund, B.Qty as RefundQty

		From ProductCategory as Br Full outer join @SaleByFromToDate as A on Br.Id = A.Id	

		Full outer join @RefundByFromToDate as B on Br.Id = B.Id

		where Br.Name = 'Special Promotion'

		

		

	End

GO
/****** Object:  StoredProcedure [dbo].[SaleItemListByDate]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SaleItemListByDate]
 @fromDate datetime,
 @toDate datetime
AS

	Select TD.ProductId as ItemId, P.Name as ItemName, SUM(TD.Qty) as ItemQty, SUM(TD.TotalAmount) as ItemTotalAmount
	from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id
	where (T.IsDeleted IS NULL or T.IsDeleted = 0) and T.Type = 'Sale' or T.Type = 'Credit' and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date)
	Group By TD.ProductId, P.Name;
	
RETURN 0






































GO
/****** Object:  StoredProcedure [dbo].[SelectItemListByDate]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SelectItemListByDate]

	@fromDate datetime,

	@toDate datetime,
	 
	 @currentshortcode varchar(2)

AS


	  Begin 

	Select P.ProductCode as ItemId, P.Name as ItemName, SUM(TD.Qty) as ItemQty, (TD.UnitPrice - (TD.UnitPrice * (TD.DiscountRate/100))) as UnitPrice,

	 SUM(TD.TotalAmount) as ItemTotalAmount, T.PaymentTypeId as PaymentTypeId, P.Size as Size, td.IsFOC ,td.SellingPrice,td.DiscountRate,

	  case when (td.IsFOC = 0) then '' else 'FOC' end  as Type

	from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id

	where T.IsDeleted = 0 and T.IsComplete = 1 and T.Type in ( 'Sale' ,'Credit' ,'GiftCard' ) and

	 CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and (TD.IsDeleted IS NULL OR

	  TD.IsDeleted = 0) and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))

	Group By P.ProductCode, P.Name, TD.UnitPrice, T.PaymentTypeId, P.Size,TD.DiscountRate, td.IsFOC,td.SellingPrice 


	union all


		Select P.ProductCode as ItemId, P.Name as ItemName, SUM(TD.Qty) as ItemQty, (TD.UnitPrice - (TD.UnitPrice * (TD.DiscountRate/100))) as UnitPrice,

	 SUM(TD.TotalAmount) as ItemTotalAmount, T.PaymentTypeId as PaymentTypeId, P.Size as Size, td.IsFOC ,td.SellingPrice ,td.DiscountRate, case when T.Type='Refund'
                                                                                then 'Refund'
                                                                        when T.type='CreditRefund'
																		then 'CreditRefund'
                                                                        end
                                                                         as Type


	from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id

	where T.IsDeleted = 0 and T.IsComplete = 1 and T.Type in ( 'Refund' ,'CreditRefund') and

	 CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and (TD.IsDeleted IS NULL OR

	  TD.IsDeleted = 0) and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))

	Group By P.ProductCode, P.Name, TD.UnitPrice, T.PaymentTypeId, P.Size,TD.DiscountRate, td.IsFOC,td.SellingPrice ,t.Type

	order by p.Name, td.IsFOC ;
	End


RETURN 0

GO
/****** Object:  StoredProcedure [dbo].[SelectItemListByDateForItemSummary]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SelectItemListByDateForItemSummary]

	@fromDate datetime,

	@toDate datetime,

	@IsSale bit,

	@ProductId int,

	@IsFOC bit,

	@currentshortcode varchar(2)



AS

	  Begin If (@IsSale = 1  or @IsFOC = 1)

	Select P.ProductCode as ItemId, P.Name as Name, SUM(TD.Qty) as Qty

	--(TD.UnitPrice - (TD.UnitPrice * (TD.DiscountRate/100))) as UnitPrice,

	 --SUM(TD.TotalAmount) as ItemTotalAmount,

	--   P.Size as Size

	from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id

	where T.IsDeleted = 0 and T.IsComplete = 1 and (T.Type = 'Sale' or T.Type = 'Credit' or T.Type = 'GiftCard') and CAST(T.DateTime as date) >= 

	CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and (TD.IsDeleted IS NULL OR TD.IsDeleted = 0)

	and (@ProductId=0 and 1=1 or @ProductId !=0 and TD.ProductId=@ProductId)
	
	and ((@IsFOC = 1  and TD.IsFOC=1) or (@IsFOC = 0 and td.IsFOC= 0))

	and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))

	Group By P.ProductCode, P.Name

	--, TD.UnitPrice, P.Size

	--,TD.DiscountRate;

   Else

   Select P.ProductCode as ItemId, P.Name as Name, SUM(TD.Qty) as Qty

   --(TD.UnitPrice - (TD.UnitPrice * (TD.DiscountRate/100))) as UnitPrice, 

   --SUM(TD.TotalAmount) as ItemTotalAmount,

   --  P.Size as Size

	from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id

	where  T.IsDeleted = 0 and (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) 

	and CAST(T.DateTime as date) <= CAST(@toDate as date) and (TD.IsDeleted IS NULL OR TD.IsDeleted = 0)

	and (@ProductId=0 and 1=1 or @ProductId !=0 and TD.ProductId=@ProductId)

	and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))

	Group By P.ProductCode, P.Name

	--, TD.UnitPrice, P.Size

	--,TD.DiscountRate;

   End

RETURN 0

GO
/****** Object:  StoredProcedure [dbo].[SelectTaxesListByDate]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SelectTaxesListByDate]
	@fromDate datetime,
	@toDate datetime,
	@IsSale bit
AS
   Begin If (@IsSale = 1)
	SELECT CAST(T.DateTime as date) as TDate, SUM(T.TaxAmount) as Amount
	FROM [Transaction] AS T
	WHERE (T.IsDeleted IS NULL or T.IsDeleted = 0) and (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date)
	GROUP BY CAST(T.DateTime as date)
   Else
    SELECT CAST(T.DateTime as date) as TDate, SUM(T.TaxAmount) as Amount
	FROM [Transaction] AS T
	WHERE (T.IsDeleted IS NULL or T.IsDeleted = 0) and T.Type = 'Refund' and CAST(T.DateTime as date) >= CAST(@fromDate  as date) and CAST(T.DateTime as date) <= CAST(@toDate as date)
	GROUP BY CAST(T.DateTime as date)
   End






































GO
/****** Object:  StoredProcedure [dbo].[StockTransactionReport]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[StockTransactionReport]
@Year int, 
@Month int
as
begin
select Product.Id as ProductID,
Product.Name as ProductName,
Product.ProductCode as ProductCode,
StockTransaction.Purchase as Purchase,
StockTransaction.Refund as Refund,
StockTransaction.Sale as Sale,
StockTransaction.AdjustmentStockIn as AdjustmentStockIn,
StockTransaction.AdjustmentStockOut,
StockTransaction.Consignment,
StockTransaction.ConversionStockIn,
StockTransaction.ConversionStockOut,
StockTransaction.StockIn,
StockTransaction.StockOut,StockTransaction.Opening
 from Product 
left join StockTransaction on StockTransaction.ProductId=Product.Id
where StockTransaction.Month=@Month and StockTransaction.Year=@Year
union  all
select Product.Id as ProductID,
Product.Name as ProductName,
Product.ProductCode as ProductCode,
isnull(0,0) as Purchase,
isnull(0,0) as Refund,
isnull(0,0) as Sale,
isnull(0,0) as AdjustmentStockIn,
isnull(0,0)as AdjustmentStockOut,
isnull(0,0)as Consignment,
isnull(0,0)as ConversionStockIn,
isnull(0,0)as ConversionStockOut,
isnull(0,0) as StockIn,
isnull(0,0)as StockOut,
isnull(product.Qty,0) as Opening
 from Product 
where Product.Id not in (select ProductId from StockTransaction where StockTransaction.Month=@Month and StockTransaction.Year=@Year)
order by Product.ProductCode
end

GO
/****** Object:  StoredProcedure [dbo].[Top100SaleItemList]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Top100SaleItemList]

 @fromDate datetime,

 @toDate datetime,

 @IsAmount bit,

 @num int,

 @currentshortcode varchar(2)

AS



 if(@IsAmount = 1) 

	Begin

		Select Top (@num) P.ProductCode as ProductCode, P.Name as ProductName, TD.DiscountRate as Discount, TD.UnitPrice as UnitPrice, SUM(TD.Qty) as Qty,
		 SUM(TD.TotalAmount) as Amount

		from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id

		where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date)
		 and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsComplete = 1
		 	and (t.ParentId Not Like('%RF%') or t.ParentId is null)

			and td.IsFOC= 0 and  ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))
		Group By P.ProductCode, P.Name, TD.DiscountRate, TD.UnitPrice

		Order By SUM(TD.TotalAmount) Desc,p.Name;

	End

 Else

	Begin

		Select Top (@num) P.ProductCode as ProductCode, P.Name as ProductName, TD.DiscountRate as Discount, TD.UnitPrice as UnitPrice, SUM(TD.Qty) as Qty,
		 SUM(TD.TotalAmount) as Amount

		from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id

		where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date)
		 and CAST(T.DateTime as date) <= CAST(@toDate as date) and T.IsComplete = 1
		 	and (t.ParentId Not Like('%RF%') or t.ParentId is null)
			and td.IsFOC= 0 and SUBSTRING(T.Id,3,2)=@currentshortcode
		Group By P.ProductCode, P.Name, TD.DiscountRate, TD.UnitPrice

		Order By SUM(TD.Qty) Desc,p.Name;

	End	

RETURN 0

GO
/****** Object:  StoredProcedure [dbo].[TransactionDetailByItem]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TransactionDetailByItem]
	@fromDate datetime,
	@toDate datetime,
	@IsSale bit,
	@MainCategoryId int,
	@SubCategoryId int,
	@BrandId int
AS
	
	Begin If(@SubCategoryId = 1)
		set @SubCategoryId = null
	End
	Begin If(@BrandId = 1)
		set @BrandId = null
	End
	
	Begin If (@IsSale = 1)	
		Begin If(@MainCategoryId = 0 and @BrandId = 0)

			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType, T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1 and (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) 
		
		Else If(@MainCategoryId =0 and @BrandId != 0)

			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType, T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1 and  (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId = @BrandId
		
		Else If(@MainCategoryId != 0 and @SubCategoryId =0 and @BrandId = 0 )
			
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType, T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1  and  (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.ProductCategoryId = @MainCategoryId

		Else If(@MainCategoryId != 0 and @SubCategoryId != 0 and @BrandId = 0)
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType, T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1 and  (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.ProductCategoryId = @MainCategoryId and P.ProductSubCategoryId = @SubCategoryId

		Else If(@MainCategoryId !=0 and @SubCategoryId = 0 and @BrandId !=0)
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType, T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1 and  (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.ProductCategoryId = @MainCategoryId and P.BrandId = @BrandId

		Else If(@MainCategoryId != 0 and @SubCategoryId != 0 and @BrandId != 0 )
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType, T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1 and  (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.ProductCategoryId = @MainCategoryId and P.ProductSubCategoryId = @SubCategoryId and P.BrandId = @BrandId
		End	
	--Refund	
	Else
		Begin If(@MainCategoryId = 0 and @BrandId = 0)

			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType, T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and  T.Type = 'Refund' and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date)
		
		Else If(@MainCategoryId =0 and @BrandId != 0)

			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType, T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and  T.Type = 'Refund' and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId = @BrandId
		
		Else If(@MainCategoryId != 0 and @SubCategoryId =0 and @BrandId = 0 )
			
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType, T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and  T.Type = 'Refund' and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.ProductCategoryId = @MainCategoryId

		Else If(@MainCategoryId != 0 and @SubCategoryId != 0 and @BrandId = 0)
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType, T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and  T.Type = 'Refund' and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.ProductCategoryId = @MainCategoryId and P.ProductSubCategoryId = @SubCategoryId

		Else If(@MainCategoryId !=0 and @SubCategoryId = 0 and @BrandId !=0)
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType, T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and  T.Type = 'Refund' and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.ProductCategoryId = @MainCategoryId and P.BrandId = @BrandId

		Else If(@MainCategoryId != 0 and @SubCategoryId != 0 and @BrandId != 0 )
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType, T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and  T.Type = 'Refund' and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.ProductCategoryId = @MainCategoryId and P.ProductSubCategoryId = @SubCategoryId and P.BrandId = @BrandId
		End	
				
	End






































GO
/****** Object:  StoredProcedure [dbo].[TransactionDetailReport]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TransactionDetailReport] --'2018-12-07','2018-12-07',1,0,0,0,0,0,'MO'

	@fromDate datetime,

	@toDate datetime,

	@IsSale bit,

	@BrandId int,

	@MainCategoryId int,

	@SubCategoryId int,

	@CounterId int,
	@IsFOC bit,
	@currentshortcode varchar(2)

	

AS

	If(@IsSale = 1 or @IsFOC=1)

	Begin 

		Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, (TD.SellingPrice * TD.Qty) as TotalAmount, 

		T.Type as TransactionType,CT.Name as [CounterName], T.DateTime as TransactionDate, td.IsFOC ,TD.DiscountRate,TD.TotalAmount as TotalReceive,T.TotalAmount as TTotal
		,t.DiscountAmount/Custom.TDCount as TDiscount

		from [Transaction] as T 

		inner join TransactionDetail as TD on T.Id = TD.TransactionId 

		inner join Product as P on TD.ProductId = P.Id

		 inner join Counter as CT on T.CounterId=CT.Id
		 inner join (select Tr.Id TRID,count(TRD.id) TDCount from [Transaction] tr,TransactionDetail trd where tr.id=trd.TransactionId and
		  (Tr.IsDeleted IS NULL or Tr.IsDeleted = 0) and (trd.IsDeleted IS NULL or trd.IsDeleted = 0) and tr.IsComplete = 1 

		and  (Tr.Type = 'Sale' or Tr.Type = 'Credit' or Tr.Type = 'GiftCard') and CAST(Tr.DateTime as date) >= CAST(@fromDate as date) 

		and CAST(Tr.DateTime as date) <= CAST(@toDate as date) and ((@currentshortcode!='0' and SUBSTRING(Tr.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))
		  group by tr.Id) as Custom on
		 t.Id=custom.TRID

		where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1 

		and  (T.Type = 'Sale' or T.Type = 'Credit' or T.Type = 'GiftCard') and CAST(T.DateTime as date) >= CAST(@fromDate as date) 

		and CAST(T.DateTime as date) <= CAST(@toDate as date) and ((@currentshortcode!='0' and SUBSTRING(T.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))

		and (((@BrandId > 0) and (p.BrandId = @BrandId)) or  ((@BrandId = 0) and (1=1)))

		and (((@MainCategoryId > 0) and (p.ProductCategoryId = @MainCategoryId)) or  ((@MainCategoryId = 0) and (1=1)))

		and (((@SubCategoryId > 0) and (p.ProductSubCategoryId = @SubCategoryId)) or  ((@SubCategoryId = 0) and (1=1)))

	and (((@CounterId > 0) and (t.CounterId = @CounterId)) or  ((@CounterId = 0) and (1=1)))
	and ((@IsFOC =1 and td.IsFOC=1) or (@IsFOC = 0 and td.IsFOC= 0))
	group by p.ProductCode,p.name,td.TransactionId,td.Qty,td.SellingPrice,t.Type,ct.Name,t.DateTime,td.IsFOC,
	td.DiscountRate,td.TotalAmount,t.TotalAmount,t.DiscountAmount,Custom.tdcount 

	End

	Else

	Begin

		Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, (TD.SellingPrice * TD.Qty) as TotalAmount, 

		T.Type as TransactionType,CT.Name as [CounterName], T.DateTime as TransactionDate, td.IsFOC ,TD.DiscountRate,TD.TotalAmount as TotalReceive,T.TotalAmount as TTotal
		,t.DiscountAmount/Custom.TDCount as TDiscount

		from [Transaction] as T  inner join TransactionDetail as TD on T.Id = TD.TransactionId 
		inner join Product as P on TD.ProductId = P.Id 

		inner join Counter as CT on T.CounterId=CT.Id  inner join (select Tr.Id TRID,count(TRD.id) TDCount from [Transaction] tr,TransactionDetail trd where tr.id=trd.TransactionId and
		  (Tr.IsDeleted IS NULL or Tr.IsDeleted = 0) and (trd.IsDeleted IS NULL or trd.IsDeleted = 0) and tr.IsComplete = 1 

		and  (Tr.Type = 'Refund' or Tr.Type = 'CreditRefund') and CAST(Tr.DateTime as date) >= CAST(@fromDate as date) 

		and CAST(Tr.DateTime as date) <= CAST(@toDate as date) and ((@currentshortcode!='0' and SUBSTRING(Tr.Id,3,2)=@currentshortcode) or (@currentshortcode='0' and 1=1))
		  group by tr.Id) as Custom on
		 t.Id=custom.TRID


		where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted=0) and  (T.Type = 'Refund' or T.Type = 'CreditRefund')

		 and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and SUBSTRING(T.Id,3,2)=@currentshortcode

		 	and ((@BrandId > 0) and (p.BrandId = @BrandId) or  ((@BrandId = 0) and (1=1)))

		and ((@MainCategoryId > 0) and (p.ProductCategoryId = @MainCategoryId) or  ((@MainCategoryId = 0) and (1=1)))

		and ((@SubCategoryId > 0) and (p.ProductSubCategoryId = @SubCategoryId) or  ((@SubCategoryId = 0) and (1=1)))

		and (((@CounterId > 0) and (t.CounterId = @CounterId)) or  ((@CounterId = 0) and (1=1)))
			group by p.ProductCode,p.name,td.TransactionId,td.Qty,td.SellingPrice,t.Type,ct.Name,t.DateTime,td.IsFOC,
	td.DiscountRate,td.TotalAmount,t.TotalAmount,t.DiscountAmount,Custom.tdcount 
	End 

RETURN 0

GO
/****** Object:  StoredProcedure [dbo].[TransactionDetailReportByBId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TransactionDetailReportByBId]
	@fromDate datetime,
	@toDate datetime,
	@IsSale bit,
	@BrandId int
	
AS
   
	If(@IsSale = 1)
	Begin 
		Begin If(@BrandId = 1)
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType,CT.Name as [Counter Name]	, T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1 and (T.Type = 'Sale' or T.Type = 'Credit' or T.Type = 'GiftCard') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId Is Null
		Else
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType,CT.Name as [Counter Name], T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1 and  (T.Type = 'Sale' or T.Type = 'Credit' or T.Type = 'GiftCard') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId = @BrandId
		End
	End
	Else
	Begin
		Begin If(@BrandId = 1)
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType
,CT.Name as [Counter Name], T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and  (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId Is Null
		Else
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType 
,CT.Name as [Counter Name], T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and  (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId = @BrandId
		End
	End 
RETURN 0






































GO
/****** Object:  StoredProcedure [dbo].[TransactionDetailReportByBIdAndCId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TransactionDetailReportByBIdAndCId]
	@fromDate datetime,
	@toDate datetime,
	@IsSale bit,
	@BrandId int,
	@MainCategoryId int
	
AS
   
	If(@IsSale = 1)
	Begin 
		Begin If(@BrandId = 1)
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType ,CT.Name as [Counter Name], T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1 and  (T.Type = 'Sale' or T.Type = 'Credit' or T.Type = 'GiftCard') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId Is Null and P.ProductCategoryId = @MainCategoryId
		Else
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType,CT.Name as [Counter Name], T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1  and (T.Type = 'Sale' or T.Type = 'Credit' or T.Type = 'GiftCard') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId = @BrandId and P.ProductCategoryId = @MainCategoryId
		End
	End
	Else
	Begin
		Begin If(@BrandId = 1)
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType ,CT.Name as [Counter Name], T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and  (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId Is Null and P.ProductCategoryId = @MainCategoryId
		Else
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType ,CT.Name as [Counter Name], T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and  (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId = @BrandId and P.ProductCategoryId = @MainCategoryId
		End
	End 
RETURN 0






































GO
/****** Object:  StoredProcedure [dbo].[TransactionDetailReportByBIdAndCIdAndSCId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TransactionDetailReportByBIdAndCIdAndSCId]
	@fromDate datetime,
	@toDate datetime,
	@IsSale bit,
	@BrandId int,
	@MainCategoryId int,
	@SubCategoryId int
	
AS
   
	If(@IsSale = 1)
	Begin 
		Begin If(@BrandId = 1)
		    Begin If (@SubCategoryId = 1)
				Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType ,CT.Name as [Counter Name], T.DateTime as TransactionDate
				from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
				where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1 and (T.Type = 'Sale' or T.Type = 'Credit' or T.Type = 'GiftCard') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId Is Null and P.ProductCategoryId = @MainCategoryId and P.ProductSubCategoryId Is Null

			Else
				Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType ,CT.Name as [Counter Name], T.DateTime as TransactionDate
				from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
				where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1 and (T.Type = 'Sale' or T.Type = 'Credit' or T.Type = 'GiftCard') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId Is Null and P.ProductCategoryId = @MainCategoryId and P.ProductSubCategoryId = @SubCategoryId
			End
			
		Else
			Begin If (@SubCategoryId = 1)
				Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType ,CT.Name as [Counter Name], T.DateTime as TransactionDate
				from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
				where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1 and (T.Type = 'Sale' or T.Type = 'Credit' or T.Type = 'GiftCard') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId = @BrandId and P.ProductCategoryId = @MainCategoryId and P.ProductSubCategoryId Is Null

			Else
				Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType ,CT.Name as [Counter Name], T.DateTime as TransactionDate
				from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
				where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1 and (T.Type = 'Sale' or T.Type = 'Credit' or T.Type = 'GiftCard') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId = @BrandId and P.ProductCategoryId = @MainCategoryId and P.ProductSubCategoryId = @SubCategoryId
			End
			
		End
	End
	Else
	Begin
		Begin If(@BrandId = 1)
		    Begin If (@SubCategoryId = 1)
				Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType,CT.Name as [Counter Name], T.DateTime as TransactionDate
				from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
				where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and  (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId Is Null and P.ProductCategoryId = @MainCategoryId and P.ProductSubCategoryId Is Null

			Else
				Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType,CT.Name as [Counter Name], T.DateTime as TransactionDate
				from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
				where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and  (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId Is Null and P.ProductCategoryId = @MainCategoryId and P.ProductSubCategoryId = @SubCategoryId
			End
			
		Else
			Begin If (@SubCategoryId = 1)
				Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType ,CT.Name as [Counter Name], T.DateTime as TransactionDate
				from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
				where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and  (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId = @BrandId and P.ProductCategoryId = @MainCategoryId and P.ProductSubCategoryId Is Null

			Else
				Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType ,CT.Name as [Counter Name], T.DateTime as TransactionDate
				from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
				where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and  (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.BrandId = @BrandId and P.ProductCategoryId = @MainCategoryId and P.ProductSubCategoryId = @SubCategoryId
			End
			
		End
		
	End 
RETURN 0






































GO
/****** Object:  StoredProcedure [dbo].[TransactionDetailReportByCId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TransactionDetailReportByCId]
	@fromDate datetime,
	@toDate datetime,
	@IsSale bit,
	@MainCategoryId int
	
AS
	If(@IsSale = 1)
	Begin 
		Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType,CT.Name as [Counter Name], T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1 and (T.Type = 'Slae' or T.Type = 'Credit' or T.Type = 'GiftCard') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.ProductCategoryId = @MainCategoryId
	End
	Else
	Begin
		Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType ,CT.Name as [Counter Name], T.DateTime as TransactionDate
		from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
		where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.ProductCategoryId = @MainCategoryId
	End 
RETURN 0






































GO
/****** Object:  StoredProcedure [dbo].[TransactionDetailReportBySCIdAndCId]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TransactionDetailReportBySCIdAndCId]
	@fromDate datetime,
	@toDate datetime,
	@IsSale bit,
	@SubCategoryId int,
	@MainCategoryId int
	
AS
   
	If(@IsSale = 1)
	Begin 
		Begin If(@SubCategoryId = 1)
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType ,CT.Name as [Counter Name], T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1 and (T.Type = 'Sale' or T.Type = 'Credit' or T.Type = 'GiftCard') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.ProductSubCategoryId Is Null and P.ProductCategoryId = @MainCategoryId
		Else
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType ,CT.Name as [Counter Name], T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and T.IsComplete = 1 and (T.Type = 'Sale' or T.Type = 'Credit' or T.Type = 'GiftCard') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.ProductSubCategoryId = @SubCategoryId and P.ProductCategoryId = @MainCategoryId
		End
	End
	Else
	Begin
		Begin If(@SubCategoryId = 1)
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType ,CT.Name as [Counter Name], T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.ProductSubCategoryId Is Null and P.ProductCategoryId = @MainCategoryId
		Else
			Select P.ProductCode as ItemNo, P.Name as ItemName, TD.TransactionId as TransactionId, TD.Qty as Qty, TD.TotalAmount, T.Type as TransactionType ,CT.Name as [Counter Name] , T.DateTime as TransactionDate
			from [Transaction] as T inner join TransactionDetail as TD on T.Id = TD.TransactionId inner join Product as P on TD.ProductId = P.Id inner join Counter as CT on T.CounterId=CT.Id
			where (T.IsDeleted IS NULL or T.IsDeleted = 0) and (TD.IsDeleted IS NULL or TD.IsDeleted = 0) and (T.Type = 'Refund' or T.Type = 'CreditRefund') and CAST(T.DateTime as date) >= CAST(@fromDate as date) and CAST(T.DateTime as date) <= CAST(@toDate as date) and P.ProductSubCategoryId = @SubCategoryId and P.ProductCategoryId = @MainCategoryId
		End
	End 
RETURN 0






































GO
/****** Object:  StoredProcedure [dbo].[UpdateTicketby_No]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UpdateTicketby_No]
(
@qr bigint
)
as
declare @localqr varchar(20)
declare @ticket varchar(20)
set @localqr=@qr
select @ticket=@localqr
update Ticket set Status=1,EnteranceDate=GETDATE(),ReadCount=1 where TicketNo=@ticket
select @@ROWCOUNT

GO
/****** Object:  StoredProcedure [dbo].[VIPReportForNoveltyAndGWP]    Script Date: 2/15/2023 11:57:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[VIPReportForNoveltyAndGWP]
	
	@customerType int,
	@fromDate datetime,
	@toDate datetime,
	@CounterId int,
	@CityId int
AS
	declare @customerTypel int
	set @customerTypel=@customerType
	declare @fromDatel datetime
	set @fromDatel=@fromDate
	declare @toDatel datetime
	set @toDatel=@toDate
	declare @CounterIdl int
	set @CounterIdl=@CounterId
	declare @CityIdl int
	set @CityIdl=@CityId

	select Cus.Title + ' ' +  Cus.Name  as Name, COUNT(T.Id) as InvoiceQty, SUM(T.TotalAmount) as Total, 
	(dbo.VIP_PurchaseProductQty(T.CustomerId, @customerTypel, @fromDatel, @toDatel) - dbo.VIP_RefundProductQty(T.CustomerId, @customerTypel, @fromDatel, @toDatel))

 as productQty, IsNull(dbo.VIP_Novelty_Qty(T.CustomerId, @customerTypel, @fromDatel, @toDatel),0) as NV_Qty, 
 IsNull(dbo.VIP_GWP_Qty(T.CustomerId, @customerTypel, @fromDatel, @toDatel),0) as GWPQty, 
 dbo.CheckNewVIP(T.CustomerId, @customerTypel, @fromDatel, @toDatel) as IsVIP
	from [Transaction] as T 
	inner join Customer as Cus on T.CustomerId = Cus.Id 
	
	where 
	 ((@CounterIdl=0 and 1=1 ) or (@CounterIdl!=0 and T.CounterId=@CounterIdl))  
	and ((@CityId=0 and 1=1) or (@CityId!=0 and Cus.CityId=@CityIdl))
	and Cus.CustomerTypeId = @customerTypel and 
	 (T.Type = 'Sale' or T.Type = 'Credit') and CAST(T.DateTime as date) >= CAST(@fromDatel as date) 
	and CAST(T.DateTime as date) <= CAST(@toDatel as date) and T.IsDeleted = 0 and T.IsComplete = 1
	and ((@customerTypel=1 and cast(t.DateTime as date) >=  cast( Cus.PromoteDate as date) )   
	or ((@customerTypel=2 and cast(t.DateTime as date)   <  cast( Cus.PromoteDate as date)  ) or (@customerTypel=2 and cus.PromoteDate is null))) 
	Group By T.CustomerId, Cus.Name,Cus.Title



GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'GWP or PWP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GiftSystem', @level2type=N'COLUMN',@level2name=N'Type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction, Refund,Draft, Debt,GiftCard' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transaction', @level2type=N'COLUMN',@level2name=N'Type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'just for Credit Transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transaction', @level2type=N'COLUMN',@level2name=N'IsPaid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If false, store as draft' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transaction', @level2type=N'COLUMN',@level2name=N'IsComplete'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Use only for Refund Transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transaction', @level2type=N'COLUMN',@level2name=N'ParentId'
GO
