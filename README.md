# Read me 

I used SnapkKit and RxSwift. I used Carthage for dependency management and all dependencies should be conveniently committed. If there are any problems, just use the following command to fetch and build them. You might also need to add the generated xcframeworks to "Frameworks, Libraries, and Embeded Content" to both targets.

```carthage update --no-use-binaries --platform iOS --use-xcframeworks```

- I thought whether I should have multiple observables like `isLoading`, `hasError` and `books` and then just bind them directly to specific views using RxCocoa. The `State` aproach I chose make the viewModel cleaner but the view rendering more cluttered. There's not much difference in this simple task but when thengs get complicated, the single state approach tends to stay much more manageable than jungling many observables. This way we only need to keep in mind the state we're at, rather than keeping in mind the states of every observable.

- I wrote the ApiClient using callbacks, later I added RxSwift to the project and just made an Rx wrapper for the original method. I think that's quite reasonable. I also ended up using the non-react version of the API client to make a mock.
