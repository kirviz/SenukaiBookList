# Read me 

I used SnapkKit and RxSwift. I used Carthage for dependency management and all dependencies should be conveniently committed. If there are any problems, just use the following command to fetch and build them. You might also need to add the generated xcframeworks to "Frameworks, Libraries, and Embeded Content" to both targets.

```carthage update --no-use-binaries --platform iOS --use-xcframeworks```

- I thought whether I should have multiple observables like `isLoading`, `hasError` and `books` and then just bind them directly to specific views using RxCocoa. The `State` aproach I chose makes less vars in the viewModel but the view now has a render function with a switch statement. There's not much difference in this simple task but when things get complicated, the single state approach tends to stay much more manageable than juggling many observables. This way we only need to keep in mind the state we're at, rather than keeping in mind the states of every observable. In the end this added a bit of trouble, namely writing State equality operators for tests, and State mapping from one state to another (instead of just mapping one value type). 

- I wrote the ApiClient using callbacks, later I added RxSwift to the project and just made an Rx wrapper for the original method. I think that's quite reasonable. I also ended up using the non-react version of the API client to make a mock.

- It's a very unexpected requirement to "show up to 5 books in a horizontal scroll" (rather than all of them) but since this is a tech task... I just went for it.

- For the sake of reducing scope, I used Apple's built-in pull to refresh functionality. It's very sad it's so bad. I improved it to refresh on release which makes it better even if the code looks a bit hacky.

- I made a singleton called Navigator, which takes care of flow control as well as some simple dependency injection, I'd say that's the best solution for this size of the app.

- I considered having 2 models BookOverview and Book and went with the option of having one model with some fields optional. It seems to make things simpler.

- I skipped the formal ViewData layer, (i.e. a transformed Model for displaying by the view) and just used the Model directly. Consequently I skipped the `configure(with data:ViewData)` methods for the views too and just used an assignable property instead. Possibly worth changing that in a bigger project. 

- I noticed sometimes I store the model in ViewModel and sometimes in View, it would be good to normalize this.

- The tests are technically integration rather then unit in my opinion. And I think it's better that way.

- There is currently no way to store the full book details back into the list for reuse. I left it that way as the database layer was in the planning. 

- The way I would do storing to database if there was more time is to basically have a wrapper for the ApiClient called BookStore perhaps. BookStore could then hold and update the results in memory as well as put into database before passing it back to the caller.
