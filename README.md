![Screenshot 2024-06-25 at 23 51 13](https://github.com/DanilaMihailov/.dotfiles/assets/1163040/e8a00dd2-05d0-4eff-83dc-e5cb40031213)


## Using GNU stow

```sh
git clone git@github.com:DanilaMihailov/.dotfiles.git dotfiles
cd dotfiles
stow -v --dotfiles */
```

`-n` - will run in simulation mode

`--dotfiles` - change `dot-` to `.` in names
