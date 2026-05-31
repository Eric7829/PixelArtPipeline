## Overview
**PixelArtPipeline** converts high-fidelity raster images into optimized Luau tables compatible with the **BedWars Scripting Toolkit** for Roblox. 

The core engineering challenge of this project is extreme color constraint optimization: mapping complex, smooth digital artwork onto a highly restrictive palette of **only 39 available in-game blocks**. Other blocks within the game asset pool feature heavy surface patterning and multi-color noise textures, making them entirely unsuitable for clean color quantization. By leveraging the CIELAB color space, Delta E perceptual distance metrics, and error-diffusion dithering, the pipeline achieves exceptional color quantization and deterministic output tailored for programmatic, in-game map generation.

### Gallery: High-Fidelity Perceptual Mapping (CIELAB)

When utilizing the CIELAB color space pipeline under standard studio lighting conditions, the algorithm achieves near-flawless color quantization and gradient blending, even within a highly restricted block palette.

| Original Image | BedWars In-Game Output (512x512 Blocks) |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/ad18382c-1ab8-418b-8c2f-a8d9b9564a7f" alt="Character_Ruan_Mei_Splash_Art" width="400"/> | <img src="https://github.com/user-attachments/assets/c578cd49-d4b1-4e39-865e-8bdde36cf32e" alt="RobloxScreenShot20260531_150916276" width="400"/> |
| **Source:** Honkai: Star Rail character splash art. | **Result:** Exceptional preservation of skin tones, complex dress gradients, and micro-details via Floyd-Steinberg dithering. |

## Highlights
- Perceptually-accurate color matching using the CIELAB color space and Delta E metrics (supports CIE76/CIEDE2000)
- Vectorized processing with NumPy for fast nearest-color lookups against a BedWars block palette
- Optional image processing: Gaussian blur, edge outlining (Canny), and configurable smoothing
- Deterministic 512×512 output tailored for BedWars map import

## Technical Details
- Color space: images are converted to CIELAB to perform distance computations that match human perception. Distance is evaluated using Delta E (configurable — CIE76 or CIEDE2000) to pick the closest BedWars palette entry.
- Nearest-neighbor search: the implementation uses a KD-Tree (scipy.spatial) or efficient NumPy broadcasting depending on availability for sub-linear or vectorized nearest-color queries.
- Quantization & dithering: color reduction is done against a precomputed BedWars palette; optional Floyd–Steinberg dithering preserves detail when mapping to the limited palette.
- Edge handling: edges can be detected with Canny and optionally outlined or smoothed using morphological operations to preserve silhouettes at low resolution.

## Requirements
- **Python 3.8+**
- **VS Code** with the [BedWars Scripting Toolkit extension](https://marketplace.visualstudio.com/items?itemName=easy-games.bedwars-scripting-toolkit) (required for syncing Lua tables to Roblox)
- See `requirements.txt` for Python dependencies

## Setup
1. Install Python dependencies:
   ```sh
   pip install -r requirements.txt
   ```
2. Install the BedWars Scripting Toolkit extension in VS Code.
3. Place your input image in the `src/` folder as `input.png` or `input.jpg`.

## Usage
Run the script from the project root:
```sh
python src/main.py
```

- Configure options (edge outlining, blur level) at the top of `main.py`.
- The output Lua table will be saved as `src/output.lua`.
- Sync this project to Bedwars (Create a custom, preferably void (squads) and open the scripts tab)
- Run `build_image.lua` in bedwars, and wait 3 seconds.

## Notes
- Only PNG and JPG/JPEG images are supported.
- Output is always 512x512 for BedWars compatibility.
- The `.gitignore` is set to ignore input/output files and VS Code settings.

## License
MIT License
