USE [master]
GO
/****** Object:  Database [mposV3]    Script Date: 8/14/2019 1:36:53 PM ******/
CREATE DATABASE [mposV3]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'mposV3', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQL\MSSQL\DATA\mposV3.mdf' , SIZE = 6144KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'mposV3_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQL\MSSQL\DATA\mposV3_log.ldf' , SIZE = 43264KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [mposV3] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [mposV3].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [mposV3] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [mposV3] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [mposV3] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [mposV3] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [mposV3] SET ARITHABORT OFF 
GO
ALTER DATABASE [mposV3] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [mposV3] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [mposV3] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [mposV3] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [mposV3] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [mposV3] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [mposV3] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [mposV3] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [mposV3] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [mposV3] SET  DISABLE_BROKER 
GO
ALTER DATABASE [mposV3] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [mposV3] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [mposV3] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [mposV3] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [mposV3] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [mposV3] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [mposV3] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [mposV3] SET RECOVERY FULL 
GO
ALTER DATABASE [mposV3] SET  MULTI_USER 
GO
ALTER DATABASE [mposV3] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [mposV3] SET DB_CHAINING OFF 
GO
ALTER DATABASE [mposV3] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [mposV3] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [mposV3] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'mposV3', N'ON'
GO
USE [mposV3]
GO
/****** Object:  UserDefinedFunction [dbo].[GetGWPGiftSetInvoiceAmount]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetGWPGiftSetQty]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetGWPName]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[Adjustment]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[AdjustmentType]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[Authorize]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[Brand]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[City]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[ConsignmentCounter]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[ConsignmentSettlement]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[ConsignmentSettlementDetail]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[Counter]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[Currency]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[Customer]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[CustomerType]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[DailyRecord]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[DeleteLog]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[ExchangeRateForTransaction]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[Expense]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[ExpenseCategory]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[ExpenseDetail]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[GiftCard]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[GiftCardInTransaction]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[GiftSystem]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[GiftSystemInTransaction]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[MainPurchase]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[MemberCardRule]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[MemberType]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[NoveltySystem]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[PaymentType]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[pjForms]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[pjForms_Localization]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[Product]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[ProductCategory]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[ProductInNovelty]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[ProductPriceChange]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[ProductQuantityChange]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[ProductSubCategory]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[PurchaseDeleteLog]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[PurchaseDetail]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[PurchaseDetailInTransaction]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[RestaurantTable]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[RoleManagement]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[Setting]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[Shop]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[SPDetail]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[StockInDetail]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[StockInHeader]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[StockTransaction]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[Supplier]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[Tax]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[Ticket]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[TicketButtonAssign]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[Townshipdb]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[Transaction]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[TransactionDetail]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[Turnstile]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[TurnStileServer]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[Unit]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[UnitConversion]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[UsePrePaidDebt]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[User]    Script Date: 8/14/2019 1:36:54 PM ******/
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
	[DateTime] [datetime] NULL CONSTRAINT [DF_User_DateTime]  DEFAULT (getdate()),
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
/****** Object:  Table [dbo].[UserRole]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  Table [dbo].[WrapperItem]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[AverageMonthlySaleReport]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[AverageMonthlySaleReportBrandId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[AverageMonthlySaleReportByBrandIdAndCounterId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[AverageMonthlySaleReportByDateTime]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[AverageMonthlySaleReportCounterId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ClearDBConnections]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[CustomerAutoID]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ExportDatabase]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetConsignmentProduct]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetCustomerCode]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetCustomerSaleByCuId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetCustomerSaleById]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetGWPSetQtyAndAmount]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetGWPTransactions]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetNoveliesSaleByCTypte]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetNoveliesSaleByCTypte1]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetNoveltiesSale]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetNoveltySaleByBrandId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetNoveltySaleByBrandId_Result]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetNoveltySaleByCType_Result]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetNoveltySaleByDate]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetNoveltySaleByDate_Result]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetNoveltySaleDate]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetProductCode]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetProductReport]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetProfitandLoss]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetProfitAndLossByBrandId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetProfitAndLossByCouterId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetProfitAndLossByProductId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetSaleSpecialPromotionByCustomerId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetSaleSpecialPromotionSegmentByCustomerId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetTicketBy_TDID]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetTicketByQr]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetTotalAmountForCash]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetTotalAmountForPrepaid]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetTotalAmountForRefund]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetTotalTransactionQtyAndQty]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetTransactionByGroup]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[InsertDraft]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[InsertRefundTransaction]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[insertSPDetail]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[InsertTicket]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[InsertTransaction]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[InsertTransactionDetail]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[NetIncomeReportByYearMonth]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Paid]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ProductCdoe]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ProductReportByBId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ProductReportByCId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ProductReportByCIdAndBId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ProductReportBySCIdAndCId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ProductReportBySCIdAndCIdAndBId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PurchaseDiscountReport]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PurchaseReport]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[RefundItemList]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SaleBreakDownByRangeWithSaleTrueValue]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SaleBreakDownByRangeWithUnitValue]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SaleBreakDownBySegmentWithSaleTrueValue]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SaleBreakDownBySegmentWithUnitValue]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SaleItemListByDate]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SelectItemListByDate]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SelectItemListByDateForItemSummary]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SelectTaxesListByDate]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[StockTransactionReport]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Top100SaleItemList]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[TransactionDetailByItem]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[TransactionDetailReport]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[TransactionDetailReportByBId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[TransactionDetailReportByBIdAndCId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[TransactionDetailReportByBIdAndCIdAndSCId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[TransactionDetailReportByCId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[TransactionDetailReportBySCIdAndCId]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateTicketby_No]    Script Date: 8/14/2019 1:36:54 PM ******/
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
/****** Object:  StoredProcedure [dbo].[VIPReportForNoveltyAndGWP]    Script Date: 8/14/2019 1:36:54 PM ******/
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
USE [master]
GO
ALTER DATABASE [mposV3] SET  READ_WRITE 
GO
