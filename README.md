
# PixelArtPipeline

<p align="center">
  <img width="300" height="300" alt="2d73e99772fd449798041808e0f3317a" src="https://github.com/user-attachments/assets/b7a71e60-caab-4a84-b9a2-4443a30cadc9" />
  <img width="300" height="300" alt="image" src="https://github.com/user-attachments/assets/19e2155d-a6c7-46e7-b635-ed2b7be045cb" />

</p>

<p align="center">
  <strong>From 16.7 Million Colors down to 39 in-game assets.</strong> 
  <br />
  Left: Original 24-bit image | Right: Roblox Bedwars Render utilizing CIELAB perceptual mapping.
</p>


### Overview
**PixelArtPipeline** converts high-fidelity raster images into optimized Luau tables compatible with the **BedWars Scripting Toolkit** for Roblox. 

The core engineering challenge of this project is extreme color constraint optimization: mathematically mapping standard 24-bit True Color images (16,777,216 possible colors) down to a highly restrictive palette of only **39 available in-game blocks—representing a 99.9997% reduction in raw color data**. Other blocks within the game asset pool feature multi-color noise textures, making them entirely unsuitable for clean color quantization. To prevent this massive compression from destroying image fidelity, the pipeline rejects naïve RGB distance formulas in favor of the CIELAB color space, using Delta E perceptual distance metrics and Floyd-Steinberg error-diffusion dithering. This achieves exceptional color quantization and deterministic output tailored for programmatic, in-game map generation.

### Gallery: High-Fidelity Perceptual Mapping (CIELAB)

The following showcases demonstrate how the pipeline handles different asset styles: from stylized game illustration to historic photo-journalism—using just 39 types of blocks.

#### Test Case 1: Stylized Game Art (Digital Illustration)
When utilizing standard studio-lit character art, the CIELAB pipeline achieves flawless color quantization and smooth gradient transitions without muddying distinct hues.

| Original Splash Art | BedWars In-Game Output (512x512 Blocks) |
| :---: | :---: |
| <img width="1024" height="1024" alt="RM Splash art" src="https://github.com/user-attachments/assets/2259cbf4-5db8-4dcf-993e-00796ba9de46" />| <img width="1012" height="1000" alt="Cropped bw" src="https://github.com/user-attachments/assets/d40ccfc8-f52d-41aa-bcc0-1f93a283f456" /> |
| **Source:** Ruan Mei Splash Art from *Honkai: Star Rail*  | **Result:** Exceptional preservation of delicate skin tones, complex dress gradients, and wood textures via Floyd-Steinberg dithering. |

---

#### Test Case 2: Real-World Photograph (Complex Human Features)
Unlike flat digital art, real-world photographs contain infinite analog gradients and micro-textures. This test demonstrates the algorithm's capability to retain dramatic atmospheric lighting and critical human facial details under extreme palette compression.

| Original Photograph | BedWars In-Game Output (512x512 Blocks) |
| :---: | :---: |
| <img src="https://upload.wikimedia.org/wikipedia/en/b/b4/Sharbat_Gula.jpg" alt="Afghan_Girl_Original" width="400"/> | <img width="484" height="746" alt="Afghan Girl" src="https://github.com/user-attachments/assets/52062937-5753-4a61-8633-ebc565eeccfa" />
 |
| **Source:** *Afghan Girl* by Steve McCurry (1984). | **Result:** Immaculate separation of complementary colors (terracotta red vs. sea-green) and crisp retention of the iconic iris color. |


## Highlights
- Perceptually-accurate color matching using the CIELAB color space and Delta E metrics (supports CIE76/CIEDE2000)
- Vectorized processing with NumPy for fast nearest-color lookups against a BedWars block palette
- Optional image processing: Gaussian blur, edge outlining (Canny), and configurable smoothing
- Deterministic 512×512 output tailored for BedWars map import

## Technical Details
- Color space: images are converted to CIELAB to perform distance computations that match human perception. Distance is evaluated using Delta E (configurable — CIE76 or CIEDE2000) to pick the closest BedWars palette entry.
- Nearest-neighbor search: the implementation uses efficient NumPy broadcasting depending on availability for sub-linear or vectorized nearest-color queries.
- Quantization & dithering: color reduction is done against a precomputed BedWars palette; optional Floyd–Steinberg dithering preserves detail when mapping to the limited palette.
- Edge handling: edges can be detected with Canny and optionally outlined or smoothed using morphological operations to preserve silhouettes at low resolution.

### ⚡ Performance & Complexity
The pipeline is highly optimized for fast, local execution, capable of processing and generating a 512x512 Lua map (262,144 pixels) in under a second. 

**Time Complexity:** $\mathcal{O}(N \cdot K)$ 
*   **$N$** = Total number of pixels ($512 \times 512 = 262,144$)
*   **$K$** = Number of colors in the BedWars palette ($39$)
*   **Breakdown:** 
    *   **Image Resizing & Preprocessing:** $\mathcal{O}(N)$ using OpenCV's highly optimized `INTER_AREA` interpolation.
    *   **Bilateral Filtering (Optional):** $\mathcal{O}(N \cdot d^2)$ where $d$ is the kernel diameter (max 15).
    *   **Color Space Conversion:** $\mathcal{O}(N)$ mapping standard RGB to CIELAB.
    *   **Distance Calculation:** $\mathcal{O}(N \cdot K)$. While a KD-Tree would offer $\mathcal{O}(N \log K)$ asymptotic search time, the small size of the palette ($K=39$) means the branching overhead of a KD-Tree is slower than brute-force vectorization. The implementation relies on NumPy broadcasting to compute the $L_2$ norm (Euclidean distance) in C-level SIMD operations, maximizing CPU cache-hits.

**Space Complexity:** $\mathcal{O}(N)$
*   To prevent MemoryErrors when broadcasting a $(262144 \times 39 \times 3)$ dimensional array, the pipeline implements **chunked processing** (batch size of $C = 10,000$). 
*   This drops peak memory allocation drastically, resulting in a space complexity of $\mathcal{O}(N + C \cdot K)$. The maximum memory footprint required to process the final image is ~5 MB.

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
# Basic usage
python src/main.py -i custom_image.jpg -o output.lua

# Advanced usage (enable dithering and Canny edge detection)
python src/main.py -i custom_image.jpg --dither --edge-outlines
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
