Deploy Module {
    By PSGalleryModule {
        FromSource Build\Curl2PS
        To PSGallery
        WithOptions @{
            ApiKey = $ENV:PSGalleryKey
        }
    }
}