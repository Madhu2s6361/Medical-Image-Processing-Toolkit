% Medical_Image_Toolkit.m
% Simple medical image preprocessing toolkit
% - Accepts a local file or an image URL
% - Handles RGB and grayscale images safely (uses im2gray)
% - Performs: grayscale -> denoise -> edge detect -> contrast adjust
% - Saves processed outputs to the current folder

function Medical_Image_Toolkit()
    clc; close all;

    fprintf("MEDICAL IMAGE PROCESSING TOOLKIT \n\n");
    fprintf("Options:\n");
    fprintf("  1) Paste an image URL (HTTP/HTTPS)\n");
    fprintf("  2) Choose a local image file (PNG/JPG/TIF/etc.)\n\n");

    choice = input("Enter 1 or 2 (default 2): ", 's');
    if isempty(choice)
        choice = '2';
    end

    img = [];
    try
        if strcmp(choice,'1')
            url = strtrim(input('Paste image URL (include http/https): ', 's'));
            if isempty(url)
                error('No URL provided.');
            end
            fprintf('Trying to read image directly from URL...\n');
            try
                img = imread(url); % try reading directly
            catch
                % fallback: download to temp file then read
                fprintf('Direct read failed, downloading to temporary file...\n');
                [~,~,ext] = fileparts(url);
                if isempty(ext)
                    ext = '.img';
                end
                tmpname = fullfile(tempdir, ['tmp_medimg' ext]);
                websave(tmpname, url);
                img = imread(tmpname);
            end
        else
            % local file dialog
            [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.tif;*.tiff;*.bmp','Image files (*.png,*.jpg,*.tif,*.bmp)';...
                                     '*.*','All files (*.*)'}, 'Select an image file');
            if isequal(file,0)
                error('No file selected. Exiting.');
            end
            img = imread(fullfile(path, file));
        end
    catch ME
        fprintf('Error loading image: %s\n', ME.message);
        return;
    end

    % Show original
    figure('Name','Original Image'); imshow(img); title('Original Image');

    % Convert to grayscale (works for RGB and for already-gray images)
    try
        grayImg = im2gray(img);    % safe for both RGB and grayscale
    catch
        % fallback if im2gray not available (older MATLAB)
        if ndims(img) == 3
            grayImg = rgb2gray(img);
        else
            grayImg = img;
        end
    end
    figure('Name','Grayscale Image'); imshow(grayImg); title('Grayscale Image');

    % Denoise (Gaussian filter) - you can change sigma
    sigma = 2; % default smoothness
    denoiseImg = imgaussfilt(grayImg, sigma);
    figure('Name','Denoised Image'); imshow(denoiseImg); title(sprintf('Denoised (Gaussian, sigma=%.1f)', sigma));

    % Edge detection - use Sobel (change method if you like)
    edgeMethod = 'sobel'; % 'canny' | 'sobel' | 'prewitt' etc.
    edgeImg = edge(denoiseImg, edgeMethod);
    figure('Name','Edge Detected Image'); imshow(edgeImg); title(sprintf('Edge Detected (%s)', edgeMethod));

    % Contrast enhancement
    contrastImg = imadjust(grayImg); % simple contrast stretch
    figure('Name','Contrast Enhanced'); imshow(contrastImg); title('Contrast Enhanced');

    % Save outputs
    out1 = 'medical_original.png';
    out2 = 'medical_grayscale.png';
    out3 = 'medical_denoised.png';
    out4 = 'medical_edges.png';
    out5 = 'medical_contrast.png';

    try
        imwrite(img, out1);
        imwrite(grayImg, out2);
        imwrite(denoiseImg, out3);
        imwrite(edgeImg, out4);
        imwrite(contrastImg, out5);
        fprintf('\nProcessing complete. Files saved in current folder:\n');
        fprintf('  %s\n  %s\n  %s\n  %s\n  %s\n', out1, out2, out3, out4, out5);
    catch ME
        fprintf('Warning: could not save one or more output files: %s\n', ME.message);
    end

    fprintf('\nDone.\n');
end
