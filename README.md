### Crypto Prices

- Shows prices in real-time for Bitcoin, Ethereum and Dogecoin.

- Allows logged in user to favorite a crypto.

- Shows how many people in total have favorited a crypto, in real-time.

## Installation

```
asdf install
mix setup
iex -S mix phx.server
```

### Considerations

The approach for "favorite totals" is not straightforward.
To avoid doing a "count" in the database on every change,
we only send increment/decrement (+/- 1) deltas to
the LiveView processes. 
As such, lost messages will result in incorrect totals
being displayed, even if future correct messages are
received.
