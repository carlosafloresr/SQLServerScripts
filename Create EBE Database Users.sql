USE [master]
GO

/****** Object:  Login [EBE_User]    Script Date: 9/1/2016 9:29:08 AM ******/
DROP LOGIN [EBE_User]
GO

/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [EBE_User]    Script Date: 9/1/2016 9:29:08 AM ******/
CREATE LOGIN [EBE_User] WITH PASSWORD=N'hzdmSFXd+bJ2PLeI9wucgyJA0qUKy0ePknybUn2EK0Q=', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

ALTER LOGIN [EBE_User] DISABLE
GO

/****** Object:  Login [EBEApp_Test]    Script Date: 9/1/2016 9:29:24 AM ******/
DROP LOGIN [EBEApp_Test]
GO

/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [EBEApp_Test]    Script Date: 9/1/2016 9:29:25 AM ******/
CREATE LOGIN [EBEApp_Test] WITH PASSWORD=N'eD+bjcAiCM2wjnLpbKdEk5KZEx5A7zNYB7pkHUMMGRE=', DEFAULT_DATABASE=[Tributary], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO

ALTER LOGIN [EBEApp_Test] DISABLE
GO