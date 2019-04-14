# Ask HN
### An iOS app for browsing Ask Hacker News

I built Ask HN to practice Swift iOS development. 
I really enjoy the discussions on [Hacker News](https://news.ycombinator.com/ask) so I wanted a quick and easy way to browse them. Most HN clients focus on the links, so I wanted to focus on the discussions for a change. If you like the idea and want to learn more about Swift, please contribute!

## Testing
I will have it on TestFlight (link to come) and if things start shaping up, I'll submit it for review. In the meantime, clone the repo and run it in the simulator or on your device through Xcode.

## Contributing
If you find an issue or think something could be better, open an issue. If you're motivated enough by the problem, fork the repo and submit a pull request. If everything works and the code is understandable, I'll happily merge it in.

## Principles
Minimal
- This project is for learning and that means minimizing features and dependencies. Since this is a simple client for displaying and sharing text, this shouldn't be a big deal. In addition, it reduces the learning curve and overhead to getting started with the project.

Read only
- The point of this app is to strictly be a client for consuming content from HN. We are not going to reverse-engineer authenticated actions (upvoting, commenting, saving, etc.). To keep things focused, this app will be read-only. We'll leverage the iOS ecosystem for sharing to enable saving and manipulating data with other apps.
