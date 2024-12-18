# restore-workspaces-ubuntu
Restore Your Ubuntu Workspace with ease

There was a problem for me that I have a bunch of workspaces I open every time I power on my PC to start working...

And everytime it's quite time consuming. Like, It took up to 5 minutes. It became a routine for me

So I started looking for a solution...

I've tried several tools but none of them did what I wanted.

So, covered by LLM agent, we created a tool that helps to recreate the workspaces with EASE!

You can create several tool scripts for any workspaces set up you want!

Let's start!

# First Step. Set Up Your Workspaces

First time, you need to manually set up your workspaces the way you want to see it.

![alt text](image-1.png)

If you have several displays, it's not a problem at all.

After all preparations and adjustings done

# Second Step. Export your current workspaces setup in JSON

## Requirements
```
sudo apt install wmctrl jq -y
```

## Run the script
```
chmod a+x ./get_ws.sh
./get_ws.sh
```
You should see `Workspace information saved to workspace_info.json`

Now,

# Third Step. Let's adjust the `restore_ws.sh` script to recreate your workspaces.

This bash script setups the workspaces as you need!
It opens desired apps via CLI and moves them into the desired workspace
The template command is:

`open_and_move app_cmd expected_title workspace_num x_start y_start width height`

It finds the certain app by looking for `expected_title`

> NOTION: Workspaces number should go in the ascending mode (to be created one by one) starting from 0.

## Option one. Adjust it manually



## Option two. Go to LLM (Claude, Ollama, ChatGPT) and write next prompt:

```
here is the contents of workspace_info.json:
 <your JSON contents>
Adjust the next bash script 'open_and_move' commands accordingly to recreate my workspaces.
<THIS BASH SCRIPT code >
```
Now, adjust them manually as LLM Agent could be wrong and be happy!



YOU ALL SET UP!
