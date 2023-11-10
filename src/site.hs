--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import Hakyll.Images        ( loadImage
                            , compressJpgCompiler
                            , resizeImageCompiler
                            , scaleImageCompiler
                            )

--------------------------------------------------------------------------------

config :: Configuration
config = defaultConfiguration
  { destinationDirectory = "../docs"
  }

main :: IO ()
main = hakyllWith config $ do
    match "images/**.jpg" $ do
        route idRoute
        compile $ loadImage 
            >>= compressJpgCompiler 75
            >>= resizeImageCompiler 200 200

    match "js/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "about.md" $ do
        route   $ setExtension "html"
        let aboutCtx =
                constField "img"  "images/me.jpg"         `mappend`
                defaultContext
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/about.html" aboutCtx
            >>= loadAndApplyTemplate "templates/default.html"          aboutCtx
            >>= relativizeUrls

    match "about.md" $ version "index" $ do
        route   $ constRoute "index.html"
        let aboutCtx =
                constField "img"  "images/me.jpg"         `mappend`
                defaultContext
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/about.html" aboutCtx
            >>= loadAndApplyTemplate "templates/default.html"          aboutCtx
            >>= relativizeUrls

    match "resume/resume.tex" $ do
        route   $ constRoute "resume.html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts)           `mappend`
                    constField "title"    "Archives"                   `mappend`
                    boolField "hasPosts" (const $ length posts /= 0)   `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext