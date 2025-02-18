using Godot;
using System;

public partial class Movement : CharacterBody2D
{
	[Export]
	public int Speed { get; set; } = 200;

	[Export]
	public float SprintMultiplier { get; set; } = 1.5f; // Sprint speed multiplier

	[Export]
	public float NormalAnimSpeed { get; set; } = 1.0f; // Normal animation speed

	[Export]
	public float SprintAnimSpeed { get; set; } = 1.5f; // Faster animation speed when sprinting

	private AnimatedSprite2D _animatedSprite;
	private string lastDirection = "down"; // Track last direction (default is down)

	public override void _EnterTree()
	{
		if (Multiplayer.HasMultiplayerPeer()) // Ensure multiplayer is active
		{
			SetMultiplayerAuthority(Multiplayer.GetUniqueId());
		}
	}

	public override void _PhysicsProcess(double delta)
	{
		// Only allow movement if this player owns the character
		if (!IsMultiplayerAuthority()) return;

		GetInput();
		MoveAndSlide();
	}

	private void GetInput()	
	{
		Vector2 inputDirection = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");

		// Check if sprint key is pressed
		float currentSpeed = Speed;
		if (Input.IsActionPressed("Sprint"))
		{
			currentSpeed *= SprintMultiplier;
			_animatedSprite.SpeedScale = SprintAnimSpeed; // Increase animation speed
		}
		else
		{
			_animatedSprite.SpeedScale = NormalAnimSpeed; // Reset to normal speed
		}

		Velocity = inputDirection * currentSpeed;

		// Store last movement direction
		if (inputDirection.X > 0)
			lastDirection = "right";
		else if (inputDirection.X < 0)
			lastDirection = "left";
		else if (inputDirection.Y > 0)
			lastDirection = "down";
		else if (inputDirection.Y < 0)
			lastDirection = "up";
	}

	public override void _Ready()
	{
		_animatedSprite = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
	}

	public override void _Process(double delta)
	{
		// Only allow animation updates if this player owns the character
		if (!IsMultiplayerAuthority()) return;

		// Play correct animation
		if (Input.IsActionPressed("ui_right"))
		{
			_animatedSprite.Play("side_walk");
			_animatedSprite.FlipH = false;
		}
		else if (Input.IsActionPressed("ui_left"))
		{
			_animatedSprite.Play("side_walk");
			_animatedSprite.FlipH = true;
		}
		else if (Input.IsActionPressed("ui_down"))
		{
			_animatedSprite.Play("front_walk");
		}
		else if (Input.IsActionPressed("ui_up"))
		{
			_animatedSprite.Play("back_walk");
		}
		else
		{
			// Play correct idle animation based on last direction
			if (lastDirection == "right" || lastDirection == "left")
			{
				_animatedSprite.Play("side_idle");
			}
			else
			{
				_animatedSprite.Play("idle");
			}
		}
	}
}
